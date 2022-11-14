import Domain
import Foundation
import PrismAPI

public extension CompressedPublicKey {
    init(compressedData: Data) {
        let ec = EC()
        let publicKey = ec.toPublicKeyFromCompressed(compressed: compressedData.toKotlinByteArray())
        self.init(uncompressed: Domain.PublicKey(fromEC: publicKey), value: compressedData)
    }
}
