import Combine
import Domain
import Foundation

protocol DIDPrivateKeyProvider {
    func getAll() -> AnyPublisher<[(did: DID, privateKeys: [PrivateKey])], Error>
    func getDIDInfo(did: DID) -> AnyPublisher<(did: DID, privateKeys: [PrivateKey])?, Error>
    func getPrivateKeys(did: DID) -> AnyPublisher<[PrivateKey]?, Error>
}
