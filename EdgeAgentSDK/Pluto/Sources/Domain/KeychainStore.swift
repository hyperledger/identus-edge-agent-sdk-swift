import Domain
import Foundation

public protocol KeychainStore {
    func addKey(_ key: KeychainStorableKey, service: String, account: String) throws
}
