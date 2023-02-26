import Combine
import Domain
import Foundation

protocol MediatorProvider {
    func getAll() -> AnyPublisher<[(did: DID, routingDID: DID, mediatorDID: DID)], Error>
}
