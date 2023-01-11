import Combine
import Domain
import Foundation

// MARK: Messaging events funcionalities
public extension PrismAgent {
    /// Start fetching the messages from the mediator
    func startFetchingMessages() {
        // Check if messagesStreamTask is nil
        guard messagesStreamTask == nil else { return }
        let manager = connectionManager
        messagesStreamTask = Task {
            // Keep trying to fetch messages until the task is cancelled
            while true {
                do {
                    // Wait for new messages to arrive
                    _ = try await manager.awaitMessages()
                    sleep(5)
                } catch {
                    // Handle errors that occur during the message fetching process
                    logger.error(error: error)
                }
            }
        }
    }

    /// Stop fetching messages
    func stopFetchingMessages() {
        messagesStreamTask?.cancel()
    }

    /// Handles the messages events and return a publisher of the messages
    /// - Returns: A publisher of the messages that emits an event with a `Message` and completed or failed with an `Error`
    func handleMessagesEvents() -> AnyPublisher<Message, Error> {
        pluto.getAllMessages()
            .flatMap { $0.publisher }
            .eraseToAnyPublisher()
    }

    /// Sends a DIDComm message through HTTP using mercury and returns a message if this is returned immediately by the REST endpoint.
    ///
    /// - Parameters:
    ///   - message: The message to be sent.
    /// - Returns: The sent message if successful, otherwise `nil`.
    /// - Throws: An error if the sending fails.
    func sendMessage(message: Message) async throws -> Message? {
        try await connectionManager.sendMessage(message)
    }

    /// Handles the received messages events and return a publisher of the messages
    /// - Returns: A publisher of the messages that emits an event with a `Message` and completed or failed with an `Error`
    func handleReceivedMessagesEvents() -> AnyPublisher<Message, Error> {
        pluto.getAllMessagesReceived()
            .flatMap { $0.publisher }
            .eraseToAnyPublisher()
//            .flatMap { message -> AnyPublisher<Message, Error> in
//                if let issueCredential = try? IssueCredential(fromMessage: message) {
//                    let credentials = try? issueCredential.getCredentialStrings().map {
//                        try pollux.parseVerifiableCredential(jwtString: $0)
//                    }
//                    guard let credential = credentials?.first else {
//                        return Just(message)
//                            .tryMap { $0 }
//                            .eraseToAnyPublisher()
//                    }
//                    return pluto
//                        .storeCredential(credential: credential)
//                        .map { message }
//                        .eraseToAnyPublisher()
//                }
//                return Just(message)
//                    .tryMap { $0 }
//                    .eraseToAnyPublisher()
//            }
//            .flatMap { [weak self] message -> AnyPublisher<Message, Error> in
//                if
//                    let self,
//                    let request = try? RequestPresentation(fromMessage: message),
//                    !self.requestedPresentations.value.contains(where: { $0.0.id == request.id })
//                {
//                    self.requestedPresentations.value = self.requestedPresentations.value + [(request, false)]
//                }
//                return Just(message)
//                    .tryMap { $0 }
//                    .eraseToAnyPublisher()
//            }
//            .eraseToAnyPublisher()
    }
}
