import Core
import DIDCommxSwift
import Domain
import Foundation

extension MercuryImpl: Mercury {
    public func packMessage(msg: Domain.Message) async throws -> String {
        try await PackEncryptedOperation(didcomm: didcomm).packEncrypted(msg: msg)
    }

    public func unpackMessage(msg: String) async throws -> Domain.Message {
        try await UnpackOperation(didcomm: didcomm, castor: castor).unpackEncrypted(messageString: msg)
    }

    public func sendMessage(msg: Domain.Message) async throws -> Data? {
        print("Preparing message of type: \(msg.piuri)")
        print("From: \(msg.from?.string)")
        print("to: \(msg.to?.string)")
        guard let toDID = msg.to else { throw MercuryError.noDIDReceiverSetError }
        let document = try await castor.resolveDID(did: toDID)
        guard
            let urlString = document.services.first?.serviceEndpoint.uri,
            let url = URL(string: urlString)
        else { throw MercuryError.noValidServiceFoundError }
        let packedMessage = try await packMessage(msg: msg)
        print("Sending message of type: \(msg.piuri)")
        return try await session.post(
            url: url,
            body: packedMessage.data(using: .utf8),
            headers: ["content-type": MediaType.contentTypeEncrypted.rawValue]
        )
    }

    public func sendMessageParseMessage(msg: Domain.Message) async throws -> Domain.Message? {
        guard
            let msgData = try await sendMessage(msg: msg),
            let msgStr = String(data: msgData, encoding: .utf8)
        else { return nil }
        return try? await self.unpackMessage(msg: msgStr)
    }
}
