import Combine
import Domain
import Foundation

protocol MessageProvider {
    func getAll() -> AnyPublisher<[Message], Error>
    func getAllFor(did: DID) -> AnyPublisher<[Message], Error>
    func getAllSent() -> AnyPublisher<[Message], Error>
    func getAllReceived() -> AnyPublisher<[Message], Error>
    func getAllSentTo(did: DID) -> AnyPublisher<[Message], Error>
    func getAllReceivedFrom(did: DID) -> AnyPublisher<[Message], Error>
    func getAllOfType(type: String, relatedWithDID: DID?) -> AnyPublisher<[Message], Error>
    func getAll(from: DID, to: DID) -> AnyPublisher<[Message], Error>
    func getMessage(id: String) -> AnyPublisher<Message?, Error>
}
