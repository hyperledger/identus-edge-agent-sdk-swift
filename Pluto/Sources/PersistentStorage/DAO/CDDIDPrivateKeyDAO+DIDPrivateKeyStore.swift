import Combine
import CoreData
import Domain

extension CDDIDPrivateKeyDAO: DIDPrivateKeyStore {
    func addDID(did: DID, privateKeys: [PrivateKey]) -> AnyPublisher<Void, Error> {
        updateOrCreate(did.string, context: writeContext) { cdobj, _ in
            cdobj.parseFrom(did: did, privateKeys: privateKeys)
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
    func parseFrom(did: DID, privateKeys: [PrivateKey]) {
        self.did = did.string
        self.schema = did.schema
        self.method = did.method
        self.methodId = did.methodId
        privateKeys.forEach {
            switch $0.curve {
            case .x25519:
                self.privateKeyKeyAgreement = $0.value
                self.curveKeyAgreement = $0.curve.storageName
            case .ed25519:
                self.privateKeyAuthenticate = $0.value
                self.curveAuthenticate = $0.curve.storageName
            case .secp256k1:
                break
            }
        }
    }
}

extension KeyCurve {
    var storageName: String {
        switch self {
        case .x25519:
            return "X25519"
        case .ed25519:
            return "Ed25519"
        case let .secp256k1(index):
            return "secp256k1-\(index)"
        }
    }

    init(storageName: String) throws {
        if
            storageName.contains("secp256k1"),
            let indexStr = storageName.components(separatedBy: "-").last,
            let index = Int(indexStr)
        {
            self = .secp256k1(index: index)
        } else {
            switch storageName {
            case "X25519":
                self = .x25519
            case "Ed25519":
                self = .ed25519
            default:
                throw CommonError.somethingWentWrongError
            }
        }
    }
}
