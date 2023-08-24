import Combine
import Foundation

extension CDLinkSecretDAO: LinkSecretProvider {
    func getAll() -> AnyPublisher<[String], Error> {
        fetchController(context: readContext)
            .map { $0.map(\.secret) }
            .eraseToAnyPublisher()
    }
}
