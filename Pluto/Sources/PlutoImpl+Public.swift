import Combine
import Domain

extension PlutoImpl: Pluto {
    public func storeDID(did: DID, keyPairIndex: Int, alias: String?) -> AnyPublisher<Void, Error> {
        registeredDIDDao.addDID(did: did, keyPairIndex: keyPairIndex, alias: alias)
    }

    public func getAllDIDs() -> AnyPublisher<[(did: DID, keyPairIndex: Int, alias: String?)], Error> {
        registeredDIDDao.getAll()
    }

    public func getDIDInfo(did: DID) -> AnyPublisher<(did: DID, keyPairIndex: Int, alias: String?)?, Error> {
        registeredDIDDao.getDIDInfo(did: did)
    }

    public func getDIDInfo(alias: String) -> AnyPublisher<[(did: DID, keyPairIndex: Int)], Error> {
        registeredDIDDao.getDIDInfo(alias: alias)
            .map { $0.map { ($0.did, $0.keyPairIndex) } }
            .eraseToAnyPublisher()
    }

    public func getDIDKeyPairIndex(did: DID) -> AnyPublisher<Int?, Error> {
        getDIDInfo(did: did)
            .map { $0?.keyPairIndex }
            .eraseToAnyPublisher()
    }
 }
