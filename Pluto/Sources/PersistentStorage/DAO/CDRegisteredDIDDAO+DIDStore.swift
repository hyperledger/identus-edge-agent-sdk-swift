import Combine
import CoreData
import Domain

extension CDRegisteredDIDDAO: DIDStore {
    func addDID(did: DID, keyPairIndex: Int, alias: String?) -> AnyPublisher<Void, Error> {
        updateOrCreate(did.string, context: writeContext) { cdobj, _ in
            cdobj.parseFrom(did: did, keyPairIndex: keyPairIndex, alias: alias)
        }
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    func removeDID(did: DID) -> AnyPublisher<Void, Error> {
        deleteByIDsPublisher([did.string], context: writeContext)
    }

    func removeAll() -> AnyPublisher<Void, Error> {
        deleteAllPublisher(context: writeContext)
    }
}

private extension CDRegisteredDID {
    func parseFrom(did: DID, keyPairIndex: Int, alias: String?) {
        self.did = did.string
        schema = did.schema
        method = did.method
        methodId = did.methodId
        keyIndex = Int64(keyPairIndex)
        self.alias = alias
    }
}
