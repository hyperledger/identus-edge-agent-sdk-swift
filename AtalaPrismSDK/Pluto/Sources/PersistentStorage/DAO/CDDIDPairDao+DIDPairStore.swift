import Combine
import CoreData
import Domain

extension CDDIDPairDAO: DIDPairStore {
    func addDIDPair(pair: DIDPair) -> AnyPublisher<Void, Error> {
        privateKeyDIDDAO
            .fetchByIDsPublisher(
                pair.holder.string,
                context: writeContext
            )
            .first()
            .tryMap { cdobj in
                guard let did = cdobj else {
                    throw PlutoError.missingDataPersistence(
                        type: "Holder DID",
                        affecting: "DID Pair"
                    )
                }
                guard did.pair == nil else {
                    throw PlutoError.duplication(type: "Holder DID/DID Pair")
                }
                return did
            }
            .flatMap { didObjc in
                updateOrCreate(pair.other.string, context: writeContext) { cdobj, context in
                    cdobj.parseFrom(
                        holder: didObjc,
                        other: pair.other,
                        name: pair.name ?? "",
                        context: context
                    )
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
