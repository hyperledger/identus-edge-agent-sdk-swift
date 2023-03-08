import Core
import CryptoKit
import Domain
import Foundation

struct SignMessageOperation {
    let logger: PrismLogger
    let privateKey: Domain.PrivateKey
    let message: Data

    init(
        logger: PrismLogger = PrismLogger(category: .apollo),
        privateKey: Domain.PrivateKey,
        message: Data
    ) {
        self.logger = logger
        self.privateKey = privateKey
        self.message = message
    }

    func compute() throws -> Signature {
        return Signature(
            value: try ECSigning(
                data: Data(SHA256.hash(data: message)),
                privateKey: privateKey.value
            ).signMessage()
        )
    }
}
