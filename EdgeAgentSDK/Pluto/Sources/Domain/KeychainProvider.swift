import Domain
import Foundation

public protocol KeychainProvider {
    func getKey(
        service: String,
        account: String,
        tag: String?,
        algorithm: KeychainStorableKeyProperties.KeyAlgorithm,
        type: KeychainStorableKeyProperties.KeyType
    ) throws -> Data
}
