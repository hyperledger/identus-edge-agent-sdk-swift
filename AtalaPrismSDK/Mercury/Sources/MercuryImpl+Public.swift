import Core
import DIDCommxSwift
import Domain
import Foundation

extension MercuryImpl: Mercury {
    /// packMessage asynchronously packs a given message object into a string representation. This function may throw an error if the message object is invalid.
    ///
    /// - Parameter msg: The message object to pack
    /// - Returns: The string representation of the packed message
    /// - Throws: An error if the message object is invalid
    public func packMessage(msg: Domain.Message) async throws -> String {
        try await PackEncryptedOperation(didcomm: didcomm, logger: logger).packEncrypted(msg: msg)
    }

    /// unpackMessage asynchronously unpacks a given string representation of a message into a message object. This function may throw an error if the string is not a valid message representation.
    ///
    /// - Parameter msg: The string representation of the message to unpack
    /// - Returns: The message object
    /// - Throws: An error if the string is not a valid message representation
    public func unpackMessage(msg: String) async throws -> Domain.Message {
        try await UnpackOperation(didcomm: didcomm, castor: castor, logger: logger).unpackEncrypted(messageString: msg)
    }

    /// sendMessage asynchronously sends a given message and returns the response data. This function may throw an error if the message is invalid or the send operation fails.
    ///
    /// - Parameter msg: The message to send
    /// - Returns: The response data
    /// - Throws: An error if the message is invalid or the send operation fails
    public func sendMessage(msg: Domain.Message) async throws -> Data? {
        guard let toDID = msg.to else { throw MercuryError.noRecipientDIDSetError }
        let document = try await castor.resolveDID(did: toDID)
        guard
            let urlString = document.services.first?.serviceEndpoint.first?.uri,
            let url = URL(string: urlString)
        else {
            logger.error(message: "Could not find a valid service on the DID to send message")
            throw MercuryError.noValidServiceFoundError(did: toDID.string)
        }
        let packedMessage = try await packMessage(msg: msg)
        return try await session.post(
            url: url,
            body: packedMessage.data(using: .utf8),
            headers: ["content-type": MediaType.contentTypeEncrypted.rawValue]
        )
    }

    /// sendMessageParseMessage asynchronously sends a given message and returns the response message object. This function may throw an error if the message is invalid, the send operation fails, or the response message is invalid.
    ///
    /// - Parameter msg: The message to send
    /// - Returns: The response message object
    /// - Throws: An error if the message is invalid, the send operation fails, or the response message is invalid
    public func sendMessageParseMessage(msg: Domain.Message) async throws -> Domain.Message? {
        guard
            let msgData = try await sendMessage(msg: msg),
            let msgStr = String(data: msgData, encoding: .utf8)
        else { return nil }
        return try? await self.unpackMessage(msg: msgStr)
    }
}
