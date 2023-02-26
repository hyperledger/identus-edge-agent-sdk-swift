import Core
import Domain
import Foundation
import PrismAPI

struct SignMessageOperation {
    let logger: PrismLogger
    let privateKey: Domain.PrivateKey
    let message: Data

    func compute() -> Signature {
        logger.debug(
            message: "Signing message",
            metadata: [
                .maskedMetadata(key: "message", value: message.description)
            ]
        )

        let ec = EC()
        let ecPrivateKey = ec.toPrivateKeyFromBytes(encoded: privateKey.value.toKotlinByteArray())
        logger.debug(message: "Decoded internaly the private key")
        return Signature(value: ec.signBytes(
            data: message.toKotlinByteArray(),
            privateKey: ecPrivateKey
        ).getEncoded().toData())
    }
}
