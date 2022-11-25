import Combine
import Domain
import Foundation

extension CDMediatorDIDDAO: MediatorProvider {
    func getAll() -> AnyPublisher<[(did: DID, routingDID: DID, url: URL)], Error> {
        fetchController(context: readContext)
            .map { $0.map { (DID(from: $0.peerDID), DID(from: $0.routingDID), url: $0.url) }}
            .eraseToAnyPublisher()
    }
}
