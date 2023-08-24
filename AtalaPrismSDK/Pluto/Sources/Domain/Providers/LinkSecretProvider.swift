import Combine
import Foundation

protocol LinkSecretProvider {
    func getAll() -> AnyPublisher<[String], Error>
}
