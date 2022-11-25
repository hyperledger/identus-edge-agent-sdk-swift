import Combine
import Domain
import Foundation

protocol DIDPairStore {
    func addDIDPair(holder: DID, other: DID, name: String) -> AnyPublisher<Void, Error>
    func removeDIDPair(holder: DID, other: DID) -> AnyPublisher<Void, Error>
    func removeAll() -> AnyPublisher<Void, Error>
}
