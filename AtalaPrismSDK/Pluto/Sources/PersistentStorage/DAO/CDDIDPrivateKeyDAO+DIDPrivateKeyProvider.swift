import Combine
import Core
import CoreData
import Domain

extension CDDIDPrivateKeyDAO: DIDPrivateKeyProvider {
    func getAll() -> AnyPublisher<[(did: DID, privateKeys: [PrivateKey], alias: String?)], Error> {
        fetchController(context: readContext)
            .flatMap { array in
                Future {
                    try await array.asyncMap {
                        (
                            DID(from: $0),
                            try await $0.parsePrivateKeys(restoration: keyRestoration),
                            $0.alias
                        )
                    }
            }}
            .eraseToAnyPublisher()
    }

    func getDIDInfo(did: DID) -> AnyPublisher<(did: DID, privateKeys: [PrivateKey], alias: String?)?, Error> {
        fetchByIDsPublisher(did.string, context: readContext)
            .flatMap { object in
                Future {
                    guard let obj = object else {
                        return nil
                    }
                    return (DID(from: obj),
                        try await obj.parsePrivateKeys(restoration: keyRestoration),
                        obj.alias
                    )
            }}
            .eraseToAnyPublisher()
    }

    func getDIDInfo(alias: String) -> AnyPublisher<[(did: DID, privateKeys: [PrivateKey], alias: String?)], Error> {
        fetchController(
            predicate: NSPredicate(format: "alias == %@", alias),
            context: readContext
        )
        .flatMap { array in
            Future {
                try await array.asyncMap {
                    (
                        DID(from: $0),
                        try await $0.parsePrivateKeys(restoration: keyRestoration),
                        $0.alias
                    )
                }
        }}
        .eraseToAnyPublisher()
    }

    func getPrivateKeys(did: DID) -> AnyPublisher<[PrivateKey]?, Error> {
        fetchByIDsPublisher(did.string, context: readContext)
            .flatMap { did in
                Future {
                    guard let didExists = did else { return nil }
                    return try await didExists.parsePrivateKeys(restoration: keyRestoration)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension CDDIDPrivateKey {
    func to(keyRestoration: KeyRestoration) -> AnyPublisher<(did: DID, privateKeys: [PrivateKey], alias: String?), Error> {
        let object = self
        return Future {
            return (
                DID(from: object),
                try await object.parsePrivateKeys(restoration: keyRestoration),
                object.alias
            )
        }.eraseToAnyPublisher()
    }
    func parsePrivateKeys(restoration: KeyRestoration) async throws -> [PrivateKey] {
        var privateKeys = [PrivateKey]()
        if
            let privateKeyKeyAgreement,
            let curveKeyAgreement,
            let key = try? await restoration.restorePrivateKey(identifier: curveKeyAgreement, data: privateKeyKeyAgreement)
        {
            privateKeys.append(key)
        }

        if
            let privateKeyAuthenticate,
            let curveAuthenticate,
            let key = try? await restoration.restorePrivateKey(identifier: curveAuthenticate, data: privateKeyAuthenticate)
        {
            privateKeys.append(key)
        }
        return privateKeys
    }
}
