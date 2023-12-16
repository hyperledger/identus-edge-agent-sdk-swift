import Combine
import Domain
import Foundation

extension PlutoImpl: Pluto {
    public func storeDID(did: Domain.DID, privateKeys: [StorableKey], alias: String?) -> AnyPublisher<Void, Error> {
        privateKeyDIDDao.addDID(did: did, privateKeys: privateKeys, alias: alias)
    }

    public func getAllDIDs() -> AnyPublisher<[(did: DID, privateKeys: [StorableKey], alias: String?)], Error> {
        privateKeyDIDDao.getAll()
    }

    public func getDIDInfo(
        did: DID
    ) -> AnyPublisher<(did: DID, privateKeys: [StorableKey], alias: String?)?, Error> {
        privateKeyDIDDao.getDIDInfo(did: did)
    }

    public func getDIDInfo(
        alias: String
    ) -> AnyPublisher<[(did: DID, privateKeys: [StorableKey], alias: String?)], Error> {
        privateKeyDIDDao.getDIDInfo(alias: alias)
    }

    public func getDIDPrivateKeys(did: DID) -> AnyPublisher<[StorableKey]?, Error> {
        privateKeyDIDDao.getPrivateKeys(did: did)
    }

    public func storePrismDID(did: DID, keyPairIndex: Int, alias: String?) -> AnyPublisher<Void, Error> {
        registeredDIDDao.addDID(did: did, keyPairIndex: keyPairIndex, alias: alias)
    }

    public func storePeerDID(did: DID, privateKeys: [StorableKey], alias: String?) -> AnyPublisher<Void, Error> {
        privateKeyDIDDao.addDID(did: did, privateKeys: privateKeys, alias: alias)
    }
    public func storeDIDPair(pair: DIDPair) -> AnyPublisher<Void, Error> {
        pairDIDDao.addDIDPair(pair: pair)
    }

    public func storeMessage(message: Message, direction: Message.Direction) -> AnyPublisher<Void, Error> {
        messageDao.addMessage(msg: message, direction: direction)
    }

    public func storeMessages(messages: [(Message, Message.Direction)]) -> AnyPublisher<Void, Error> {
        messageDao.addMessages(messages: messages)
    }

    public func storeMediator(peer: DID, routingDID: DID, mediatorDID: DID) -> AnyPublisher<Void, Error> {
        mediatorDAO.addMediator(peer: peer, routingDID: routingDID, mediatorDID: mediatorDID)
    }

    public func storeCredential(credential: StorableCredential) -> AnyPublisher<Void, Error> {
        credentialsDAO.addCredential(credential: credential)
    }

    public func getAllPrismDIDs() -> AnyPublisher<[(did: DID, keyPairIndex: Int, alias: String?)], Error> {
        registeredDIDDao.getAll()
    }

    public func getPrismDIDInfo(did: DID) -> AnyPublisher<(did: DID, keyPairIndex: Int, alias: String?)?, Error> {
        registeredDIDDao.getDIDInfo(did: did)
    }

    public func getPrismDIDInfo(alias: String) -> AnyPublisher<[(did: DID, keyPairIndex: Int)], Error> {
        registeredDIDDao.getDIDInfo(alias: alias)
            .map { $0.map { ($0.did, $0.keyPairIndex) } }
            .eraseToAnyPublisher()
    }

    public func getPrismDIDKeyPairIndex(did: DID) -> AnyPublisher<Int?, Error> {
        getPrismDIDInfo(did: did)
            .map { $0?.keyPairIndex }
            .eraseToAnyPublisher()
    }

    public func getPrismLastKeyPairIndex() -> AnyPublisher<Int, Error> {
        privateKeyDIDDao.getLastKeyIndex()
    }

    public func getAllPeerDIDs() -> AnyPublisher<[(did: DID, privateKeys: [StorableKey], alias: String?)], Error> {
        privateKeyDIDDao.getAll().map {
            $0.filter {
                $0.did.method == "peer"
            }
        }.eraseToAnyPublisher()
    }

    public func getPeerDIDInfo(
        did: DID
    ) -> AnyPublisher<(did: DID, privateKeys: [StorableKey], alias: String?)?, Error> {
        privateKeyDIDDao.getDIDInfo(did: did).filter {
            $0?.did.method == "peer"
        }.eraseToAnyPublisher()
    }

    public func getPeerDIDInfo(
        alias: String
    ) -> AnyPublisher<[(did: DID, privateKeys: [StorableKey], alias: String?)], Error> {
        privateKeyDIDDao.getDIDInfo(alias: alias).map {
            $0.filter {
                $0.did.method == "peer"
            }
        }.eraseToAnyPublisher()
    }

    public func getPeerDIDPrivateKeys(did: DID) -> AnyPublisher<[StorableKey]?, Error> {
        privateKeyDIDDao.getPrivateKeys(did: did)
    }

    public func getAllDidPairs() -> AnyPublisher<[DIDPair], Error> {
        pairDIDDao.getAll()
    }

    public func getPair(otherDID: DID) -> AnyPublisher<DIDPair?, Error> {
        pairDIDDao.getPair(otherDID: otherDID)
    }

    public func getPair(name: String) -> AnyPublisher<DIDPair?, Error> {
        pairDIDDao.getPair(name: name)
    }

    public func getPair(holderDID: DID) -> AnyPublisher<DIDPair?, Error> {
        pairDIDDao.getPair(holderDID: holderDID)
    }

    public func getAllMessages() -> AnyPublisher<[Message], Error> {
        messageDao.getAll()
    }

    public func getAllMessages(did: DID) -> AnyPublisher<[Message], Error> {
        messageDao.getAllFor(did: did)
    }

    public func getAllMessagesSent() -> AnyPublisher<[Message], Error> {
        messageDao.getAllSent()
    }

    public func getAllMessagesReceived() -> AnyPublisher<[Message], Error> {
        messageDao.getAllReceived()
    }

    public func getAllMessagesSentTo(did: DID) -> AnyPublisher<[Message], Error> {
        messageDao.getAllSentTo(did: did)
    }

    public func getAllMessagesReceivedFrom(did: DID) -> AnyPublisher<[Message], Error> {
        messageDao.getAllReceivedFrom(did: did)
    }

    public func getAllMessagesOfType(type: String, relatedWithDID: DID?) -> AnyPublisher<[Message], Error> {
        messageDao.getAllOfType(type: type, relatedWithDID: relatedWithDID)
    }

    public func getAllMessages(from: DID, to: DID) -> AnyPublisher<[Message], Error> {
        messageDao.getAll(from: from, to: to)
    }
    public func getMessage(id: String) -> AnyPublisher<Message?, Error> {
        messageDao.getMessage(id: id)
    }

    public func getAllMediators() -> AnyPublisher<[(did: DID, routingDID: DID, mediatorDID: DID)], Error> {
        mediatorDAO.getAll()
    }

    public func getAllCredentials() -> AnyPublisher<[StorableCredential], Error> {
        credentialsDAO.getAll()
    }
    
    public func storeLinkSecret(secret: StorableKey) -> AnyPublisher<Void, Error> {
        keyDao.addLinkSecret(secret)
    }
    
    public func getLinkSecret() -> AnyPublisher<[StorableKey], Error> {
        keyDao.getAll()
    }
}
