import Combine
import CoreData
import Domain

extension CDDIDPairDAO: DIDPairStore {
    func addDIDPair(holder: DID, other: DID, name: String) -> AnyPublisher<Void, Error> {
        privateKeyDIDDAO
            .fetchByIDsPublisher(holder.string, context: writeContext)
            .first()
            .tryMap { cdobj in
                guard let did = cdobj else { throw PlutoError.invalidHolderDIDNotPersistedError }
                guard did.pair == nil else { throw PlutoError.holderDIDAlreadyPairingError }
                return did
            }
            .flatMap { didObjc in
                updateOrCreate(other.string, context: writeContext) { cdobj, context in
                    cdobj.parseFrom(holder: didObjc, other: other, name: name, context: context)
                }
            }
            .map { _ in }
            .eraseToAnyPublisher()
    }

    func removeDIDPair(holder: DID, other: DID) -> AnyPublisher<Void, Error> {
        deleteByIDsPublisher([holder.string + other.string], context: writeContext)
    }

    func removeAll() -> AnyPublisher<Void, Error> {
        deleteAllPublisher(context: writeContext)
    }
}

private extension CDDIDPair {
    func parseFrom(holder: CDDIDPrivateKey, other: DID, name: String, context: NSManagedObjectContext) {
        self.did = other.string
        self.schema = other.schema
        self.method = other.method
        self.methodId = other.methodId
        self.name = name
        self.holderDID = holder
    }
}
