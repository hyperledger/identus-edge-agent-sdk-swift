import Combine
import Domain
import Foundation

protocol DIDPairStore {
    func addDIDPair(pair: DIDPair) -> AnyPublisher<Void, Error>
    func removeDIDPair(holder: DID, other: DID) -> AnyPublisher<Void, Error>
    func removeAll() -> AnyPublisher<Void, Error>
}
