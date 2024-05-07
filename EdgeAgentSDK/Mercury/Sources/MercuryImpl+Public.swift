import Core
import DIDCommSwift
import Domain
import Foundation

extension MercuryImpl: Mercury {
    /// packMessage asynchronously packs a given message object into a string representation. This function may throw an error if the message object is invalid.
    ///
    /// - Parameter msg: The message object to pack
    /// - Returns: The string representation of the packed message
    /// - Throws: An error if the message object is invalid
    public func packMessage(msg: Domain.Message) async throws -> String {
        try await PackEncryptedOperation(didcomm: getDidcomm(), message: msg, logger: logger).packEncrypted()
    }

    /// unpackMessage asynchronously unpacks a given string representation of a message into a message object. This function may throw an error if the string is not a valid message representation.
    ///
    /// - Parameter msg: The string representation of the message to unpack
    /// - Returns: The message object
    /// - Throws: An error if the string is not a valid message representation
    public func unpackMessage(msg: String) async throws -> Domain.Message {
        try await UnpackOperation(didcomm: getDidcomm(), castor: castor, logger: logger).unpackEncrypted(messageString: msg)
    }
}
