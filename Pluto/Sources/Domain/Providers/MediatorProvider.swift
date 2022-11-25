import Combine
import Domain
import Foundation

protocol MediatorProvider {
    func getAll() -> AnyPublisher<[(did: DID, routingDID: DID, url: URL)], Error>
}
