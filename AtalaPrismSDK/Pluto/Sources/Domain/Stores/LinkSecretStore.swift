import Combine
import Foundation

protocol LinkSecretStore {
    func addLinkSecret(_ linkSecret: String) -> AnyPublisher<Void, Error>
}
