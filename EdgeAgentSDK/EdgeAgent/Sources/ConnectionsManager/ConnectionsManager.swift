import Combine
import Core
import Domain
import Foundation

class ConnectionsManagerImpl: ConnectionsManager {
    let mediationHandler: MediatorHandler
    private let castor: Castor
    private let mercury: Mercury
    private let pluto: Pluto
    private var pairings = [DIDPair]()
    private var cancellables = [AnyCancellable]()

    init(
        castor: Castor,
        mercury: Mercury,
        pluto: Pluto,
        mediationHandler: MediatorHandler,
        pairings: [DIDPair] = []
    ) {
        self.mediationHandler = mediationHandler
        self.castor = castor
        self.mercury = mercury
        self.pluto = pluto
        self.pairings = pairings
    }

    func startMediator() async throws {
        guard
            try await mediationHandler.bootRegisteredMediator() != nil
        else { throw EdgeAgentError.noMediatorAvailableError }
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
                .storeDIDPair(pair: paired)
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

    func registerMediator(hostDID: DID) async throws {
        try await mediationHandler.achieveMediation(host: hostDID)
    }
}

extension ConnectionsManagerImpl: DIDCommConnection {
    func sendMessage(_ message: Message) async throws -> Message? {
        let mercury = self.mercury
        return try await pluto
            .storeMessage(message: message, direction: .sent)
            .flatMap {
                Future {
                    try await mercury.sendMessageParseMessage(msg: message)
                }
            }
            .first()
            .await()
    }

    func awaitMessages() async throws -> [Message] {
        let stream: AnyPublisher<[Message], Error> = try awaitMessages()

        for try await value in stream.values {
            return value
        }
        return []
    }

    func awaitMessages() throws -> AnyPublisher<[Message], Error> {
        guard mediationHandler.mediator != nil else { throw EdgeAgentError.noMediatorAvailableError }
        let mediationHandler = mediationHandler
        let pluto = pluto
        return Future {
            try await mediationHandler.pickupUnreadMessages(limit: 10)
        }
        .flatMap { messages in
            pluto
                .storeMessages(messages: messages.map { ($0.1, .received) })
                .map { messages }
        }
        .flatMap { messages in
            Future {
                try await mediationHandler.registerMessagesAsRead(ids: messages.map { $0.0 })
                return messages.map { $0.1 }
            }
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

    func getMessagesPublisher(message: Message) -> AnyPublisher<Message, Error> {
        struct RetryError: Error {}
        let mercury = self.mercury
        return Future<Result<Message, Error>, Error> { promise in
            Task {
                do {
                    guard
                        let message = try await mercury.sendMessageParseMessage(msg: message)
                    else {
                        promise(.failure(RetryError()))
                        return
                    }

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
