import Combine
import CoreData
import Domain

extension CDRegisteredDIDDAO: DIDProvider {
    func getAll() -> AnyPublisher<[(did: DID, keyPairIndex: Int, alias: String?)], Error> {
        fetchController(context: readContext)
            .map { $0.map { (DID(from: $0), Int($0.keyIndex), $0.alias) } }
            .eraseToAnyPublisher()
    }

    func getDIDInfo(
        alias: String
    ) -> AnyPublisher<[(did: DID, keyPairIndex: Int, alias: String?)], Error> {
        fetchByKeyValuePublisher(key: "alias", value: alias, context: readContext)
            .map { $0.map {
                (DID(from: $0), Int($0.keyIndex), $0.alias)
            }}
            .eraseToAnyPublisher()
    }

    func getDIDInfo(
        did: DID
    ) -> AnyPublisher<(did: DID, keyPairIndex: Int, alias: String?)?, Error> {
        fetchByKeyValuePublisher(key: "did", value: did.string, context: readContext)
            .map { $0.first.map {
                (DID(from: $0), Int($0.keyIndex), $0.alias)
            }}
            .eraseToAnyPublisher()
    }

    func getDIDInfo(
        keyPairIndex: Int
    ) -> AnyPublisher<(did: DID, keyPairIndex: Int, alias: String?)?, Error> {
        fetchController(
            predicate: NSPredicate(
                format: "%K == %@", "keyIndex", NSNumber(value: keyPairIndex)
            ),
            context: readContext
        )
        .map { $0.first.map {
            (DID(from: $0), Int($0.keyIndex), $0.alias)
        }}
        .eraseToAnyPublisher()
    }
}

private extension DID {
    init(from: CDDID) {
        self.init(
            schema: from.schema,
            method: from.method,
            methodId: from.methodId
        )
    }
}
