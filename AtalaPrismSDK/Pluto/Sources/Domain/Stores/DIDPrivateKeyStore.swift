import Combine
import Domain
import Foundation

protocol DIDPrivateKeyStore {
    func addDID(did: DID, privateKeys: [PrivateKey], alias: String?) -> AnyPublisher<Void, Error>
    func removeDID(did: DID) -> AnyPublisher<Void, Error>
    func removeAll() -> AnyPublisher<Void, Error>
}
