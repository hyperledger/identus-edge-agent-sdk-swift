import Domain
import Foundation

public protocol DIDCommConnection {
    func awaitMessages() async throws -> [Message]
    func awaitMessageResponse(id: String) async throws -> Message?
    @discardableResult
    func sendMessage(_ message: Message) async throws -> Message?
}

protocol ConnectionsManager {
    func addConnection(_ paired: DIDPair) async throws
    func removeConnection(_ pair: DIDPair) async throws -> DIDPair?
}
