import Combine
import Domain

protocol DIDStore {
    func addDID(did: DID, keyPairIndex: Int, alias: String?) -> AnyPublisher<Void, Error>
    func removeDID(did: DID) -> AnyPublisher<Void, Error>
    func removeAll() -> AnyPublisher<Void, Error>
}

extension DIDStore {
    func addDID(did: DID, keyPairIndex: Int, alias: String? = nil) -> AnyPublisher<Void, Error> {
        addDID(did: did, keyPairIndex: keyPairIndex, alias: alias)
    }
}
