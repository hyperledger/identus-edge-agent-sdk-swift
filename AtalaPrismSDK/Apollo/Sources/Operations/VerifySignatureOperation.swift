import Core
import CryptoKit
import Domain
import Foundation

struct VerifySignatureOperation {
    let logger: PrismLogger
    let publicKey: Domain.PublicKey
    let challenge: Data
    let signature: Signature

    init(
        logger: PrismLogger = PrismLogger(category: .apollo),
        publicKey: Domain.PublicKey,
        challenge: Data,
        signature: Signature
    ) {
        self.logger = logger
        self.publicKey = publicKey
        self.challenge = challenge
        self.signature = signature
    }

    func compute() throws -> Bool {
        try ECVerify(
            signature: signature.value,
            message: challenge,
            publicKey: publicKey.value
        ).verifySignature()
    }
}
