import Combine
import Domain
import Foundation

extension PlutoImpl: Pluto {
    public func storePrismDID(did: DID, keyPairIndex: Int, alias: String?) -> AnyPublisher<Void, Error> {
        registeredDIDDao.addDID(did: did, keyPairIndex: keyPairIndex, alias: alias)
    }

    public func storePeerDID(did: DID, privateKeys: [PrivateKey]) -> AnyPublisher<Void, Error> {
        privateKeyDIDDao.addDID(did: did, privateKeys: privateKeys)
    }
    public func storeDIDPair(holder: DID, other: DID, name: String) -> AnyPublisher<Void, Error> {
        pairDIDDao.addDIDPair(holder: holder, other: other, name: name)
    }

    public func storeMessage(message: Message) -> AnyPublisher<Void, Error> {
        messageDao.addMessage(msg: message)
    }

    public func storeMessages(messages: [Message]) -> AnyPublisher<Void, Error> {
        messageDao.addMessages(messages: messages)
    }

    public func storeMediator(peer: DID, routingDID: DID, mediatorDID: DID) -> AnyPublisher<Void, Error> {
        mediatorDAO.addMediator(peer: peer, routingDID: routingDID, mediatorDID: mediatorDID)
    }

    public func storeCredential(credential: VerifiableCredential) -> AnyPublisher<Void, Error> {
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
        registeredDIDDao.getLastKeyPairIndex()
    }

    public func getAllPeerDIDs() -> AnyPublisher<[(did: DID, privateKeys: [PrivateKey])], Error> {
        privateKeyDIDDao.getAll()
    }

    public func getPeerDIDInfo(did: DID) -> AnyPublisher<(did: DID, privateKeys: [PrivateKey])?, Error> {
        privateKeyDIDDao.getDIDInfo(did: did)
    }

    public func getPeerDIDPrivateKeys(did: DID) -> AnyPublisher<[PrivateKey]?, Error> {
        privateKeyDIDDao.getPrivateKeys(did: did)
    }

    public func getAllDidPairs() -> AnyPublisher<[(holder: DID, other: DID, name: String?)], Error> {
        pairDIDDao.getAll()
    }

    public func getPair(otherDID: DID) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error> {
        pairDIDDao.getPair(otherDID: otherDID)
    }

    public func getPair(name: String) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error> {
        pairDIDDao.getPair(name: name)
    }

    public func getPair(holderDID: DID) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error> {
        pairDIDDao.getPair(holderDID: holderDID)
    }

    public func getAllMessages() -> AnyPublisher<[Message], Error> {
        messageDao.getAll()
    }

    public func getAllMessages(did: DID) -> AnyPublisher<[Message], Error> {
        messageDao.getAllFor(did: did)
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

    public func getAllCredentials() -> AnyPublisher<[VerifiableCredential], Error> {
        credentialsDAO.getAll()
    }
}
