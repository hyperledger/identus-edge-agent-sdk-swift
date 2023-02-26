import Core
import Domain
import Foundation
import PrismAPI

struct VerifySignatureOperation {
    let logger: PrismLogger
    let publicKey: Domain.PublicKey
    let challenge: Data
    let signature: Signature

    func compute() -> Bool {
        logger.debug(
            message: "Verifying signature",
            metadata: [
                .maskedMetadata(key: "challenge", value: challenge.description),
                .publicMetadata(key: "signature", value: signature.value.description)
            ]
        )
        let ec = EC()
        let publicKey = ec.toPublicKeyFromBytes(encoded: publicKey.value.toKotlinByteArray())
        logger.debug(message: "Decoded internaly the public key")
        let verification = ec.verifyBytes(
            data: challenge.toKotlinByteArray(),
            publicKey: publicKey,
            signature: ec.toSignatureFromBytes(encoded: signature.value.toKotlinByteArray())
        )
        logger.debug(
            message: "Signature verification \(verification ? "succeded" : "failed")",
            metadata: [
                .maskedMetadata(key: "challenge", value: challenge.description),
                .publicMetadata(key: "signature", value: signature.value.description)
            ]
        )
        return verification
    }
}
