import Combine
import Core
import Domain
import Foundation

class ConnectionsManagerImpl: ConnectionsManager {
    struct Mediator {
        let peerDID: DID
        let routingDID: DID
        let mediatorDID: DID
    }

    private let castor: Castor
    private let mercury: Mercury
    private let pluto: Pluto
    private var pairings = [DIDPair]()
    private var mediator: Mediator?
    private var cancellables = [AnyCancellable]()

    init(
        castor: Castor,
        mercury: Mercury,
        pluto: Pluto,
        pairings: [DIDPair] = []
    ) {
        self.castor = castor
        self.mercury = mercury
        self.pluto = pluto
        self.pairings = pairings
    }

    func startMediator() async throws {
        let pluto = self.pluto
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return }
            pluto
                .getAllMediators()
                .first()
                .map { $0.first }
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        continuation.resume(returning: ())
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: {
                    $0.map {
                        self.mediator = .init(
                            peerDID: $0.did,
                            routingDID: $0.routingDID,
                            mediatorDID: $0.mediatorDID
                        )
                    }
                })
                .store(in: &self.cancellables)
        }
        guard mediator != nil else { throw PrismAgentError.noMediatorAvailableError }
    }

    func stopAllEvents() {
        cancellables.forEach { $0.cancel() }
    }

    func awaitForMessageResponse(id: String) async throws -> Message? {
        return try await awaitMessageResponse(id: id)
    }

    func addConnection(_ paired: DIDPair) async throws {
        guard !pairings.contains(paired) else { return }
        let pluto = self.pluto
        try await withCheckedThrowingContinuation { continuation in
            pluto
                .storeDIDPair(holder: paired.holder, other: paired.other, name: paired.name ?? "")
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: {
                    continuation.resume(returning: $0)
                })
                .store(in: &self.cancellables)
        }
        pairings.append(paired)
    }

    func removeConnection(_ pair: DIDPair) async throws -> DIDPair? {
        pairings.firstIndex(of: pair).map {
            pairings.remove(at: $0)
        }
    }

    func registerMediator(hostDID: DID, mediatorDID: DID) async throws {
        let mercury = self.mercury
        let pluto = self.pluto

        guard
            let message: Message = try await mercury
                .sendMessageParseMessage(msg: MediationRequest(
                    from: hostDID,
                    to: mediatorDID
                ).makeMessage())
        else { throw PrismAgentError.mediationRequestFailedError }

        let grantMessage = try MediationGrant(fromMessage: message)
        let routingDID = try castor.parseDID(str: grantMessage.body.routingDid)

        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return }
            pluto
                .storeMediator(
                    peer: hostDID,
                    routingDID: routingDID,
                    mediatorDID: mediatorDID
                )
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        self.mediator = .init(
                            peerDID: hostDID,
                            routingDID: routingDID,
                            mediatorDID: mediatorDID
                        )
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: {
                    continuation.resume(returning: $0)
                })
                .store(in: &self.cancellables)
        }
    }
}

extension ConnectionsManagerImpl: DIDCommConnection {
    func awaitMessages() async throws -> [Message] {
        let stream: AnyPublisher<[Message], Error> = try awaitMessages()

        for try await value in stream.values {
            return value
        }
        return []
    }

    func awaitMessages() throws -> AnyPublisher<[Message], Error> {
        guard let mediator else { throw PrismAgentError.noMediatorAvailableError }
        let mercury = self.mercury
        let pluto = self.pluto
        return getMessagesPublisher(message: try PickUpRequest(
            from: mediator.peerDID,
            to: mediator.mediatorDID,
            body: .init(
                limit: "10"
            )
        ).makeMessage())
        .flatMap { msg in
            Future {
                try await PickupRunner(message: msg, mercury: mercury).run()
            }
        }
        .flatMap { messages in
            pluto
                .storeMessages(messages: messages)
                .map { messages }
        }
        .eraseToAnyPublisher()
    }

    func awaitMessageResponse(id: String) async throws -> Message? {
        let stream: AnyPublisher<[Message], Error> = try awaitMessages()

        for try await value in stream.values {
            if let message = value.first(where: { $0.thid == id }) {
                return message
            }
        }
        return nil
    }

    private func getMessagesPublisher(message: Message) -> AnyPublisher<Message, Error> {
        struct RetryError: Error {}
        let mercury = self.mercury
        return Future<Result<Message, Error>, Error> { promise in
            Task {
                do {
                    guard
                        let messageData = try await mercury.sendMessage(msg: message),
                        let messageString = String(data: messageData, encoding: .utf8)
                    else {
                        promise(.failure(RetryError()))
                        return
                    }

                    let message = try await mercury.unpackMessage(msg: messageString)
                    promise(.success(Result.success(message)))
                } catch {
                    promise(.success(Result.failure(error)))
                }
            }
        }
        .catch {
            switch $0 {
            case is RetryError:
                return Fail<Result<Message, Error>, Error>(error: $0)
                    .delay(for: 5, scheduler: DispatchQueue.global())
                    .eraseToAnyPublisher()
            default:
                return Just(.failure($0))
                    .tryMap { $0 }
                    .eraseToAnyPublisher()
            }
        }
        .retry(10)
        .eraseToAnyPublisher()
        .tryMap {
            switch $0 {
            case let .success(message):
                return message
            case let .failure(error):
                throw error
            }
        }
        .eraseToAnyPublisher()
    }
}
