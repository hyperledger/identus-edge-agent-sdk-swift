import Combine
import Core
import DIDCommxSwift
import Domain
import Foundation

final class PackEncryptedOperation: OnPackEncryptedResult {
    private let didcomm: DIDCommProtocol
    private let logger: PrismLogger
    private var published = CurrentValueSubject<String?, Error>(nil)
    private var cancellable: AnyCancellable?

    init(didcomm: DIDCommProtocol, logger: PrismLogger) {
        self.didcomm = didcomm
        self.logger = logger
    }

    func packEncrypted(msg: Domain.Message) async throws -> String {
        guard let fromDID = msg.from else { throw MercuryError.noSenderDIDSetError }
        guard let toDID = msg.to else { throw MercuryError.noRecipientDIDSetError }

        let result: String = try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return }
            self.cancellable = self.published
                .drop(while: { $0 == nil })
                .first()
                .sink(receiveCompletion: { [weak self] in
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        self?.logger.error(
                            message: "Could not pack message",
                            metadata: [
                                .publicMetadata(key: "Error", value: error.localizedDescription)
                            ]
                        )
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: {
                    guard let result = $0 else { return }
                    continuation.resume(returning: result)
                })
            do {
                let status = didcomm.packEncrypted(
                    msg: try DIDCommxSwift.Message(domain: msg, mediaType: .contentTypePlain),
                    to: toDID.string,
                    from: fromDID.string,
                    signBy: nil,
                    options: .init(
                        protectSender: false,
                        forward: false,
                        forwardHeaders: nil,
                        messagingService: nil,
                        encAlgAuth: .a256cbcHs512Ecdh1puA256kw,
                        encAlgAnon: .xc20pEcdhEsA256kw
                    ),
                    cb: self
                )
                switch status {
                case.success:
                    break
                case .error:
                    continuation.resume(throwing: MercuryError.didcommError(
                        msg: "Unknown error on initializing pack encrypted function"
                    ))
                }
            } catch let error {
                continuation.resume(throwing: MercuryError.didcommError(
                    msg: "Error on parsing Domain message to DIDComm library model: \(error.localizedDescription)"
                ))
            }
        }
        return result
    }

    func success(result: String, metadata: PackEncryptedMetadata) {
        published.send(result)
        published.send(completion: .finished)
    }

    func error(err: DIDCommxSwift.ErrorKind, msg: String) {
        logger.error(
            message: "Packing message failed with error",
            metadata: [
                .publicMetadata(
                    key: "Error",
                    value: MercuryError
                        .didcommError(msg: msg)
                        .localizedDescription
                )
            ]
        )
        published.send(completion: .failure(MercuryError.didcommError(
            msg: "Error on trying to pack encrypted a message: \(msg)"
        )))
    }
}
