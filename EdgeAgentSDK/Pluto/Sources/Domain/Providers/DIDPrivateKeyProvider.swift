import Combine
import Domain
import Foundation

protocol DIDPrivateKeyProvider {
    func getAll() -> AnyPublisher<[(did: DID, privateKeys: [StorableKey], alias: String?)], Error>
    func getDIDInfo(did: DID) -> AnyPublisher<(did: DID, privateKeys: [StorableKey], alias: String?)?, Error>
    func getDIDInfo(alias: String) -> AnyPublisher<[(did: DID, privateKeys: [StorableKey], alias: String?)], Error>
    func getPrivateKeys(did: DID) -> AnyPublisher<[StorableKey]?, Error>
    func getLastKeyIndex() -> AnyPublisher<Int, Error>
}
