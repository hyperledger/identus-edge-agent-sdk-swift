import Combine
import Domain

protocol DIDProvider {
    func getAll() -> AnyPublisher<[(did: DID, keyPairIndex: Int, alias: String?)], Error>
    func getDIDInfo(
        alias: String
    ) -> AnyPublisher<[(did: DID, keyPairIndex: Int, alias: String?)], Error>
    func getDIDInfo(
        did: DID
    ) -> AnyPublisher<(did: DID, keyPairIndex: Int, alias: String?)?, Error>
    func getDIDInfo(
        keyPairIndex: Int
    ) -> AnyPublisher<(did: DID, keyPairIndex: Int, alias: String?)?, Error>
}
