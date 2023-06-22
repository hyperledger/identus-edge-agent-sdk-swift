import Combine
import CoreData
import Domain

extension CDDIDPrivateKeyDAO: DIDPrivateKeyStore {
    func addDID(did: DID, privateKeys: [PrivateKey & StorableKey], alias: String?) -> AnyPublisher<Void, Error> {
        updateOrCreate(did.string, context: writeContext) { cdobj, _ in
            cdobj.parseFrom(did: did, privateKeys: privateKeys, alias: alias)
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
    func parseFrom(did: DID, privateKeys: [PrivateKey & StorableKey], alias: String?) {
        self.alias = alias
        self.did = did.string
        self.schema = did.schema
        self.method = did.method
        self.methodId = did.methodId
        privateKeys.forEach {
            guard
                let curveStr = $0.getProperty(.curve),
                let curve = KnownKeyCurves(rawValue: curveStr)
            else { return }
            switch curve {
            case .x25519:
                self.privateKeyAuthenticate = $0.storableData
                self.curveAuthenticate = $0.restorationIdentifier
            case .ed25519:
                self.privateKeyAuthenticate = $0.storableData
                self.curveAuthenticate = $0.restorationIdentifier
            case .secp256k1:
                self.privateKeyAuthenticate = $0.storableData
                self.curveAuthenticate = $0.restorationIdentifier
                break
            }
        }
    }
}
