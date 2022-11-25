import Combine
import CoreData
import Domain

extension CDDIDPrivateKeyDAO: DIDPrivateKeyProvider {
    func getAll() -> AnyPublisher<[(did: DID, privateKey: PrivateKey)], Error> {
        fetchController(context: readContext)
            .map { $0.map {
                (DID(from: $0), PrivateKey(curve: $0.curve, value: $0.privateKey))
            }}
            .eraseToAnyPublisher()
    }

    func getDIDInfo(did: DID) -> AnyPublisher<(did: DID, privateKey: PrivateKey)?, Error> {
        fetchByIDsPublisher(did.string, context: readContext)
            .map {
                $0.map { (DID(from: $0), PrivateKey(curve: $0.curve, value: $0.privateKey))}
            }
            .eraseToAnyPublisher()
    }
    func getPrivateKey(did: DID) -> AnyPublisher<PrivateKey?, Error> {
        fetchByIDsPublisher(did.string, context: readContext)
            .map { did in
                did.map { PrivateKey(curve: $0.curve, value: $0.privateKey) }
            }
            .eraseToAnyPublisher()
    }
}
