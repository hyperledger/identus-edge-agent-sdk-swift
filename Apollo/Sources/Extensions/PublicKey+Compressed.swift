import Domain
import Foundation
import PrismAPI

extension Domain.PublicKey {
    init(fromEC: ECPublicKey) {
        self.init(curve: ECConfig().CURVE_NAME, value: fromEC.getEncoded().toData())
    }

    public func compressed() -> CompressedPublicKey {
        let ec = EC()
        let publicKey = ec.toPublicKeyFromBytes(encoded: value.toKotlinByteArray())
        return CompressedPublicKey(
            uncompressed: self,
            value: publicKey.getEncodedCompressed().toData()
        )
    }
}
