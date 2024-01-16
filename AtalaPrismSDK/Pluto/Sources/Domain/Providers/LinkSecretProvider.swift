import Combine
import Domain
import Foundation

protocol LinkSecretProvider {
    func getLinkSecret() -> AnyPublisher<StorableKey?, Error>
}
