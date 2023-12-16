import Combine
import Domain
import Foundation

protocol LinkSecretStore {
    func addLinkSecret(_ linkSecret: StorableKey) -> AnyPublisher<Void, Error>
}
