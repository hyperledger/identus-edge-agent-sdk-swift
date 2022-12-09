import Foundation

public protocol Mercury {
    func packMessage(msg: Domain.Message) async throws -> String
    func unpackMessage(msg: String) async throws -> Domain.Message
    @discardableResult
    func sendMessage(msg: Message) async throws -> Data?
    @discardableResult
    func sendMessageParseMessage(msg: Message) async throws -> Message?
}
