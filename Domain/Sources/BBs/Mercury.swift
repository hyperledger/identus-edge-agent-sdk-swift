import Foundation

public protocol Mercury {
    /// packMessage asynchronously packs a given message object into a string representation. This function may throw an error if the message object is invalid.
    ///
    /// - Parameter msg: The message object to pack
    /// - Returns: The string representation of the packed message
    /// - Throws: An error if the message object is invalid
    func packMessage(msg: Domain.Message) async throws -> String

    /// unpackMessage asynchronously unpacks a given string representation of a message into a message object. This function may throw an error if the string is not a valid message representation.
    ///
    /// - Parameter msg: The string representation of the message to unpack
    /// - Returns: The message object
    /// - Throws: An error if the string is not a valid message representation
    func unpackMessage(msg: String) async throws -> Domain.Message

    /// sendMessage asynchronously sends a given message and returns the response data. This function may throw an error if the message is invalid or the send operation fails.
    ///
    /// - Parameter msg: The message to send
    /// - Returns: The response data
    /// - Throws: An error if the message is invalid or the send operation fails
    @discardableResult
    func sendMessage(msg: Message) async throws -> Data?

    /// sendMessageParseMessage asynchronously sends a given message and returns the response message object. This function may throw an error if the message is invalid, the send operation fails, or the response message is invalid.
    ///
    /// - Parameter msg: The message to send
    /// - Returns: The response message object
    /// - Throws: An error if the message is invalid, the send operation fails, or the response message is invalid
    @discardableResult
    func sendMessageParseMessage(msg: Message) async throws -> Message?
}
