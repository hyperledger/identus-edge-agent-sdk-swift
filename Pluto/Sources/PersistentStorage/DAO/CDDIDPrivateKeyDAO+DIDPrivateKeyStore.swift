import Combine
import CoreData
import Domain

extension CDDIDPrivateKeyDAO: DIDPrivateKeyStore {
    func addDID(did: DID, privateKey: PrivateKey) -> AnyPublisher<Void, Error> {
        updateOrCreate(did.string, context: writeContext) { cdobj, _ in
            cdobj.parseFrom(did: did, privateKey: privateKey)
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

private extension CDDIDPrivateKey {
    func parseFrom(did: DID, privateKey: PrivateKey) {
        self.did = did.string
        self.schema = did.schema
        self.method = did.method
        self.methodId = did.methodId
        self.privateKey = privateKey.value
        self.curve = privateKey.curve
    }
}
