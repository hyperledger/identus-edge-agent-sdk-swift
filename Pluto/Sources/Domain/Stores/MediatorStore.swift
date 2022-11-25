import Combine
import Domain
import Foundation

protocol MediatorStore {
    func addMediator(peer: DID, routingDID: DID, url: URL) -> AnyPublisher<Void, Error>
    func removeMediator(peer: DID) -> AnyPublisher<Void, Error>
}
