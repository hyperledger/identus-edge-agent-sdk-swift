import Combine
import CoreData
import Domain

extension CDDIDPrivateKeyDAO: DIDPrivateKeyProvider {
    func getAll() -> AnyPublisher<[(did: DID, privateKeys: [PrivateKey])], Error> {
        fetchController(context: readContext)
            .tryMap { try $0.map { (
                    DID(from: $0),
                    try $0.parsePrivateKeys()
                )
            }}
            .eraseToAnyPublisher()
    }

    func getDIDInfo(did: DID) -> AnyPublisher<(did: DID, privateKeys: [PrivateKey])?, Error> {
        fetchByIDsPublisher(did.string, context: readContext)
            .tryMap {
                try $0.map { (
                    DID(from: $0),
                    try $0.parsePrivateKeys()
                )
            }}
            .eraseToAnyPublisher()
    }
    func getPrivateKeys(did: DID) -> AnyPublisher<[PrivateKey]?, Error> {
        fetchByIDsPublisher(did.string, context: readContext)
            .tryMap { did in
                try did.map { try $0.parsePrivateKeys() } }
            .eraseToAnyPublisher()
    }
}

extension CDDIDPrivateKey {
    func parsePrivateKeys() throws -> [PrivateKey] {
        var privateKeys = [PrivateKey]()
        if
            let privateKeyKeyAgreement,
            let curveKeyAgreement
        {
            privateKeys.append(PrivateKey(
                curve: try KeyCurve(storageName: curveKeyAgreement),
                value: privateKeyKeyAgreement
            ))
        }
        if
            let privateKeyAuthenticate,
            let curveAuthenticate
        {
            privateKeys.append(PrivateKey(
                curve: try KeyCurve(storageName: curveAuthenticate),
                value: privateKeyAuthenticate
            ))
        }
        return privateKeys
    }
}
