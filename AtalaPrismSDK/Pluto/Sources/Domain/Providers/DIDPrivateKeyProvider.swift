import Combine
import Domain
import Foundation

protocol DIDPrivateKeyProvider {
    func getAll() -> AnyPublisher<[(did: DID, privateKeys: [PrivateKeyD], alias: String?)], Error>
    func getDIDInfo(did: DID) -> AnyPublisher<(did: DID, privateKeys: [PrivateKeyD], alias: String?)?, Error>
    func getDIDInfo(alias: String) -> AnyPublisher<[(did: DID, privateKeys: [PrivateKeyD], alias: String?)], Error>
    func getPrivateKeys(did: DID) -> AnyPublisher<[PrivateKeyD]?, Error>
}
