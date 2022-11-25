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
        guard let toDID = msg.to else { throw MercuryError.noDIDReceiverSetError }
        let document = try await castor.resolveDID(did: toDID)
        guard
            let urlString = document.services.first?.serviceEndpoint.uri,
            let url = URL(string: urlString)
        else { throw MercuryError.noValidServiceFoundError }
        let packedMessage = try await packMessage(msg: msg)

        return try await session.post(
            url: url,
            body: packedMessage.data(using: .utf8),
            headers: ["content-type": MediaType.contentTypeEncrypted.rawValue]
        )
    }
}
