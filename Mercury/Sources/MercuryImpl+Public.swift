import Domain
import Foundation

extension MercuryImpl: Mercury {
    public func packMessage(msg: Message) async throws -> (result: String, signBy: String) {
        ("", "")
    }

    public func unpackMessage(
        msg: String,
        options: UnpackOptions
    ) async throws -> (result: Message, metadata: UnpackMetadata) {
        (Message(
            piuri: "",
            body: Data(),
            createdTime: Date(),
            expiresTimePlus: Date()
        ), UnpackMetadata()
        )
    }

    public func sendMessage(msg: Message) async throws -> Data? {
        guard let toDID = msg.to else { throw MercuryError.noDIDReceiverSetError }
        let document = try castor.resolveDID(did: toDID)
        guard
            let urlString = document.services.first?.service,
            let url = URL(string: urlString)
        else { throw MercuryError.noValidServiceFoundError }
        let packedMessage = try await packMessage(msg: msg)

        return try await session.post(
            url: url,
            body: packedMessage.result.data(using: .utf8),
            headers: ["content-type": MediaType.contentTypeEncrypted.rawValue]
        )
    }
}
