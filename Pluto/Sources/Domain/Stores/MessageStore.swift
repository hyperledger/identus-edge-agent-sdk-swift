import Combine
import Domain
import Foundation

protocol MessageStore {
    func addMessages(messages: [Message]) -> AnyPublisher<Void, Error>
    func addMessage(msg: Message) -> AnyPublisher<Void, Error>
    func removeMessage(id: String) -> AnyPublisher<Void, Error>
    func removeAll() -> AnyPublisher<Void, Error>
}
