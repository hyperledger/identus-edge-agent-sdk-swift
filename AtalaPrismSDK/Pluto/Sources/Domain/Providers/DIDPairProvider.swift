import Combine
import Domain
import Foundation

protocol DIDPairProvider {
    func getAll() -> AnyPublisher<[DIDPair], Error>
    func getPair(otherDID: DID) -> AnyPublisher<DIDPair?, Error>
    func getPair(name: String) -> AnyPublisher<DIDPair?, Error>
    func getPair(holderDID: DID) -> AnyPublisher<DIDPair?, Error>
}
