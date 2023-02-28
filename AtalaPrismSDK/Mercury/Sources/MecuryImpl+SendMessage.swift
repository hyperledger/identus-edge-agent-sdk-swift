import Domain
import Foundation

extension MercuryImpl {
    /// sendMessage asynchronously sends a given message and returns the response data. This function may throw an error if the message is invalid or the send operation fails.
    ///
    /// - Parameter msg: The message to send
    /// - Returns: The response data
    /// - Throws: An error if the message is invalid or the send operation fails
    public func sendMessage(_ msg: Message) async throws -> Data? {
        guard let toDID = msg.to else { throw MercuryError.noRecipientDIDSetError }
        guard let fromDID = msg.from else { throw MercuryError.noRecipientDIDSetError }
        print("Send message \(msg.piuri) sender:\(fromDID.string) \nto:\(toDID.string)")
        let document = try await castor.resolveDID(did: toDID)

        let originalPackedMessage = try await packMessage(msg: msg)
        if
            requiresForwarding(document: document),
            let mediatorDID = getDIDCommDID(document: document),
            let encryptedData = originalPackedMessage.data(using: .utf8)
        {
            let forwardMessage = try prepareForwardMessage(
                msg: msg,
                encrypted: encryptedData,
                mediatorDID: mediatorDID
            )
            print("Send message \(forwardMessage.piuri) sender:\(forwardMessage.from?.string) \nto:\(forwardMessage.to?.string)")
            let forwardPackedMessage = try await packMessage(msg: forwardMessage)
            let mediatorDocument = try await castor.resolveDID(did: mediatorDID)
            guard
                let url = getDIDCommURL(document: mediatorDocument),
                let data = forwardPackedMessage.data(using: .utf8)
            else {
                throw MercuryError.noValidServiceFoundError(did: mediatorDID.string)
            }
            return try await sendHTTPMessage(url: url, packedMessage: data)
        } else {
            guard
                let url = getDIDCommURL(document: document),
                let data = originalPackedMessage.data(using: .utf8)
            else {
                throw MercuryError.noValidServiceFoundError(did: toDID.string)
            }
            return try await sendHTTPMessage(url: url, packedMessage: data)
        }
    }

    /// sendMessageParseMessage asynchronously sends a given message and returns the response message object. This function may throw an error if the message is invalid, the send operation fails, or the response message is invalid.
    ///
    /// - Parameter msg: The message to send
    /// - Returns: The response message object
    /// - Throws: An error if the message is invalid, the send operation fails, or the response message is invalid
    public func sendMessageParseMessage(msg: Message) async throws -> Message? {
        guard
            let msgData = try await sendMessage(msg),
            let msgStr = String(data: msgData, encoding: .utf8),
            msgStr != "null"
        else { return nil }
        print("Data returned: \(msgStr)")
        return try? await self.unpackMessage(msg: msgStr)
    }

    private func sendHTTPMessage(url: URL, packedMessage: Data) async throws -> Data? {
        return try await session.post(
            url: url,
            body: packedMessage,
            headers: ["content-type": MediaType.contentTypeEncrypted.rawValue]
        )
    }
    private func prepareForwardMessage(msg: Message, encrypted: Data, mediatorDID: DID) throws -> Message {
        guard let fromDID = msg.from else { throw MercuryError.noSenderDIDSetError }
        guard let toDID = msg.to else { throw MercuryError.noRecipientDIDSetError }
        return try ForwardMessage(
            from: fromDID,
            to: mediatorDID,
            body: .init(next: toDID.string),
            encryptedJsonMessage: encrypted
        ).makeMessage()
    }

    private func getDIDCommURL(document: DIDDocument) -> URL? {
        document.services
            .first { $0.type.contains("DIDCommMessaging") }
            .map {
                $0.serviceEndpoint
                    .map { URL(string: $0.uri) }
                    .compactMap { $0 }
            }?.first
    }

    private func getDIDCommDID(document: DIDDocument) -> DID? {
        document.services
            .first { $0.type.contains("DIDCommMessaging") }
            .map {
                $0.serviceEndpoint
                    .map { try? DID(string: $0.uri) }
                    .compactMap { $0 }
            }?.first
    }

    private func requiresForwarding(document: DIDDocument) -> Bool {
        if getDIDCommDID(document: document) != nil {
            return true
        } else {
            return false
        }
    }
}
