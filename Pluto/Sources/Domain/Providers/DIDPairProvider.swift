import Combine
import Domain
import Foundation

protocol DIDPairProvider {
    func getAll() -> AnyPublisher<[(holder: DID, other: DID, name: String?)], Error>
    func getPair(otherDID: DID) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error>
    func getPair(name: String) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error>
    func getPair(holderDID: DID) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error>
}
