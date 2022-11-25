import Combine
import Foundation

public protocol Pluto {
    func storePrismDID(
        did: DID,
        keyPairIndex: Int,
        alias: String?
    ) -> AnyPublisher<Void, Error>
    func storePeerDID(did: DID, privateKey: PrivateKey) -> AnyPublisher<Void, Error>
    func storeDIDPair(holder: DID, other: DID, name: String) -> AnyPublisher<Void, Error>
    func storeMessage(message: Message) -> AnyPublisher<Void, Error>
    func storeMessages(messages: [Message]) -> AnyPublisher<Void, Error>
    func storeMediator(peer: DID, routingDID: DID, mediatorDID: DID) -> AnyPublisher<Void, Error>

    func getAllPrismDIDs() -> AnyPublisher<[(did: DID, keyPairIndex: Int, alias: String?)], Error>
    func getPrismDIDInfo(did: DID) -> AnyPublisher<(did: DID, keyPairIndex: Int, alias: String?)?, Error>
    func getPrismDIDInfo(alias: String) -> AnyPublisher<[(did: DID, keyPairIndex: Int)], Error>
    func getPrismDIDKeyPairIndex(did: DID) -> AnyPublisher<Int?, Error>
    func getPrismLastKeyPairIndex() -> AnyPublisher<Int, Error>

    func getAllPeerDIDs() -> AnyPublisher<[(did: DID, privateKey: PrivateKey)], Error>
    func getPeerDIDInfo(did: DID) -> AnyPublisher<(did: DID, privateKey: PrivateKey)?, Error>
    func getPeerDIDPrivateKey(did: DID) -> AnyPublisher<PrivateKey?, Error>

    func getAllDidPairs() -> AnyPublisher<[(holder: DID, other: DID, name: String?)], Error>
    func getPair(otherDID: DID) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error>
    func getPair(name: String) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error>
    func getPair(holderDID: DID) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error>

    func getAllMessages() -> AnyPublisher<[Message], Error>
    func getAllMessages(did: DID) -> AnyPublisher<[Message], Error>
    func getAllMessagesSentTo(did: DID) -> AnyPublisher<[Message], Error>
    func getAllMessagesReceivedFrom(did: DID) -> AnyPublisher<[Message], Error>
    func getAllMessagesOfType(type: String, relatedWithDID: DID?) -> AnyPublisher<[Message], Error>
    func getAllMessages(from: DID, to: DID) -> AnyPublisher<[Message], Error>
    func getMessage(id: String) -> AnyPublisher<Message?, Error>

    func getAllMediators() -> AnyPublisher<[(did: DID, routingDID: DID, mediatorDID: DID)], Error>
}
