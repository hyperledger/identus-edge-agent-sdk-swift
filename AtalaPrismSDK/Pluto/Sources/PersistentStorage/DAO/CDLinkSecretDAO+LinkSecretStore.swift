import Combine
import CoreData
import Domain

extension CDLinkSecretDAO: LinkSecretStore {
    func addLinkSecret(_ linkSecret: String) -> AnyPublisher<Void, Error> {
        updateOrCreate(linkSecret, context: writeContext) { cdobj, context in
            cdobj.secret = linkSecret
        }
        .map { _ in }
        .eraseToAnyPublisher()
    }
}
