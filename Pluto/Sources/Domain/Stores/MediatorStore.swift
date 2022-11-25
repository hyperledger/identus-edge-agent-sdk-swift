import Combine
import Domain
import Foundation

protocol MediatorStore {
    func addMediator(peer: DID, routingDID: DID, mediatorDID: DID) -> AnyPublisher<Void, Error>
    func removeMediator(peer: DID) -> AnyPublisher<Void, Error>
}
