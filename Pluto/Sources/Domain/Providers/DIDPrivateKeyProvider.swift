import Combine
import Domain
import Foundation

protocol DIDPrivateKeyProvider {
    func getAll() -> AnyPublisher<[(did: DID, privateKey: PrivateKey)], Error>
    func getDIDInfo(did: DID) -> AnyPublisher<(did: DID, privateKey: PrivateKey)?, Error>
    func getPrivateKey(did: DID) -> AnyPublisher<PrivateKey?, Error>
}
