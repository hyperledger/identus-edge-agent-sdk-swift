import Combine
import Domain
import Foundation

struct Connection {
    let holderDID: DID
    let otherDID: DID
    private let mercury: Mercury

    init(
        holderDID: DID,
        otherDID: DID,
        mercury: Mercury
    ) {
        self.holderDID = holderDID
        self.otherDID = otherDID
        self.mercury = mercury
    }

    func awaitMessages() async throws -> [Message] {
        let stream: AnyPublisher<[Message], Error> = awaitMessages()

        for try await value in stream.values {
            return value
        }
        return []
    }

    func awaitMessages() -> AnyPublisher<[Message], Error> {
        let mercury = self.mercury
        return getMessagesPublisher(message: PickUpRequest(
            from: holderDID,
            to: otherDID,
            body: .init(
                limit: "10"
            )
        ).makeMessage())
        .tryMap {
            try PickupRunner(message: $0, mercury: mercury).run()
        }
        .eraseToAnyPublisher()
    }

    func awaitMessageResponse(id: String) async throws -> Message? {
        let stream: AnyPublisher<[Message], Error> = awaitMessages()

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

                    let message = try mercury.unpackMessage(
                        msg: messageString,
                        options: .expectDecryptByAllKeys
                    ).result
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

extension Connection: Equatable {
    static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.holderDID == rhs.holderDID && lhs.otherDID == rhs.otherDID
    }
}

extension Connection: DIDCommConnection {}
