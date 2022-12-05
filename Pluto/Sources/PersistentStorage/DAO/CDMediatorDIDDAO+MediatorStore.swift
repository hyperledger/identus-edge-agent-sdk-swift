import Combine
import Domain
import Foundation

extension CDMediatorDIDDAO: MediatorStore {
    func addMediator(peer: DID, routingDID: DID, mediatorDID: DID) -> AnyPublisher<Void, Error> {
        privateKeyDIDDao
            .fetchByIDsPublisher(peer.string, context: writeContext)
            .first()
            .tryMap { cdobj in
                guard let did = cdobj else { throw PlutoError.invalidHolderDIDNotPersistedError }
                return did
            }
            .flatMap { peerDID in
                self.createCDDID(did: routingDID)
                    .map { (peerDID, $0) }
                    .eraseToAnyPublisher()
            }
            .flatMap { peerDID, routingDID in
                self.createCDDID(did: mediatorDID)
                    .map { (peerDID, routingDID, $0) }
                    .eraseToAnyPublisher()
            }
            .flatMap { peerDID, routingDID, mediatorDID  in
                updateOrCreate(peer.string, context: writeContext) { cdobj, _ in
                    cdobj.parseFrom(peerDID: peerDID, routingDID: routingDID, mediatorDID: mediatorDID)
                }
            }
            .map { _ in }
            .eraseToAnyPublisher()
    }

    func removeMediator(peer: DID) -> AnyPublisher<Void, Error> {
        deleteByIDsPublisher([peer.string], context: writeContext)
    }

    private func createCDDID(did: DID) -> AnyPublisher<CDDID, Error> {
        self.didDAO
            .updateOrCreate(
                did.string,
                context: writeContext
            ) { cdobj, _ in
                cdobj.parseFrom(did: did)
            }
            .map {
                guard let did = self.didDAO.fetchByID($0, context: writeContext) else {
                    // TODO: Replace with a proper error
                    fatalError("This should never happen")
                }
                return did
            }
            .eraseToAnyPublisher()
    }
}

private extension CDMediatorDID {
    func parseFrom(peerDID: CDDIDPrivateKey, routingDID: CDDID, mediatorDID: CDDID) {
        self.peerDID = peerDID
        self.routingDID = routingDID
        self.mediatorDID = mediatorDID
    }
}
