import Foundation

public protocol Mercury {
    func packMessage(msg: Domain.Message) async throws -> String
    func unpackMessage(msg: String) async throws -> Domain.Message
    @discardableResult
    func sendMessage(msg: Message) async throws -> Data?
}

public extension Mercury {
    func sendMessage(msg: Message) async throws -> Message? {
        guard
            let msgData = try await sendMessage(msg: msg),
            let msgStr = String(data: msgData, encoding: .utf8)
        else { return nil }
        return try await self.unpackMessage(msg: msgStr)
    }
}
