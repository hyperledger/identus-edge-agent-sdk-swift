import Combine
import DIDCommxSwift
import Domain
import Foundation

final class PackEncryptedOperation: OnPackEncryptedResult {
    private let didcomm: DIDCommProtocol
    private var published = CurrentValueSubject<String?, Error>(nil)
    private var cancellable: AnyCancellable?

    init(didcomm: DIDCommProtocol) {
        self.didcomm = didcomm
    }

    func packEncrypted(msg: Domain.Message) async throws -> String {
        guard
            let fromDID = msg.from,
            let toDID = msg.to
        else { throw MercuryError.fromFieldNotSetError }
        let status = didcomm.packEncrypted(
            msg: try DIDCommxSwift.Message(domain: msg, mediaType: .contentTypeEncrypted),
            to: toDID.string,
            from: fromDID.string,
            signBy: nil,
            options: .init(
                protectSender: false,
                forward: true,
                forwardHeaders: [:],
                messagingService: nil,
                encAlgAuth: .a256cbcHs512Ecdh1puA256kw,
                encAlgAnon: .xc20pEcdhEsA256kw
            ),
            cb: self
        )

        switch status {
        case.success:
            return try await withCheckedThrowingContinuation { [weak self] continuation in
                guard let self else { return }
                self.cancellable = self.published
                    .drop(while: { $0 == nil })
                    .first()
                    .sink(receiveCompletion: {
                        switch $0 {
                        case .finished:
                            break
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: {
                        guard let result = $0 else { return }
                        continuation.resume(returning: result)
                    })
            }
        case .error:
            throw MercuryError.unknowPackingMessageError
        }
    }

    func success(result: String, metadata: PackEncryptedMetadata) {
        print("[PackEncrypted] SUCESS:\n")
        print("Result: ", result)
        print("Metadata: ", metadata)
        published.send(result)
        published.send(completion: .finished)
    }

    func error(err: DIDCommxSwift.ErrorKind, msg: String) {
        published.send(completion: .failure(MercuryError.didcommError(msg: msg)))
    }
}
