import Combine
import Core
import DIDCommSwift
import Domain
import Foundation

final class PackEncryptedOperation {
    private let didcomm: DIDComm
    private let logger: SDKLogger
    private let message: Domain.Message
    private var published = CurrentValueSubject<String?, Error>(nil)
    private var cancellable: AnyCancellable?

    init(didcomm: DIDComm, message: Domain.Message, logger: SDKLogger) {
        self.didcomm = didcomm
        self.logger = logger
        self.message = message
    }

    func packEncrypted() async throws -> String {
        guard let fromDID = message.from else { throw MercuryError.noSenderDIDSetError }
        guard let toDID = message.to else { throw MercuryError.noRecipientDIDSetError }
        
        return try await didcomm.packEncrypted(params: .init(
            message: .init(domain: message, mediaType: .contentTypeEncrypted),
            to: [toDID.string],
            from: fromDID.string,
            encAlgAuth: .a256CBCHS512
        )).packedMessage
    }
}
