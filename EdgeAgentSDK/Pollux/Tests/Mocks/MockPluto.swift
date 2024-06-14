import Combine
import Domain
import Foundation

class MockPluto: Pluto {
    var credentials = [StorableCredential]()

    func storePrismDID(did: Domain.DID, keyPairIndex: Int, alias: String?) -> AnyPublisher<Void, Error> {
        Just(()).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func storePeerDID(did: Domain.DID, privateKeys: [Domain.StorableKey], alias: String?) -> AnyPublisher<Void, Error> {
        Just(()).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func storeDID(did: Domain.DID, privateKeys: [Domain.StorableKey], alias: String?) -> AnyPublisher<Void, Error> {
        Just(()).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func storeDIDPair(pair: Domain.DIDPair) -> AnyPublisher<Void, Error> {
        Just(()).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func storeMessage(message: Domain.Message, direction: Domain.Message.Direction) -> AnyPublisher<Void, Error> {
        Just(()).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func storeMessages(messages: [(Domain.Message, Domain.Message.Direction)]) -> AnyPublisher<Void, Error> {
        Just(()).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func storeMediator(peer: Domain.DID, routingDID: Domain.DID, mediatorDID: Domain.DID) -> AnyPublisher<Void, Error> {
        Just(()).tryMap { $0 }.eraseToAnyPublisher()
    }

    func storeCredentials(credentials: [any StorableCredential]) -> AnyPublisher<Void, any Error> {
        self.credentials.append(contentsOf: credentials)
        return Just(()).tryMap { $0 }.eraseToAnyPublisher()
    }

    func storeCredential(credential: Domain.StorableCredential) -> AnyPublisher<Void, Error> {
        credentials.append(credential)
        return Just(()).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func storeLinkSecret(secret: StorableKey) -> AnyPublisher<Void, Error> {
        return Just(()).tryMap { $0 }.eraseToAnyPublisher()
    }

    func getAllPrismDIDs() -> AnyPublisher<[(did: Domain.DID, keyPairIndex: Int, alias: String?)], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getPrismDIDInfo(did: Domain.DID) -> AnyPublisher<(did: Domain.DID, keyPairIndex: Int, alias: String?)?, Error> {
        Just(nil).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getPrismDIDInfo(alias: String) -> AnyPublisher<[(did: Domain.DID, keyPairIndex: Int)], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getPrismDIDKeyPairIndex(did: Domain.DID) -> AnyPublisher<Int?, Error> {
        Just(nil).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getPrismLastKeyPairIndex() -> AnyPublisher<Int, Error> {
        Just(0).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getAllPeerDIDs() -> AnyPublisher<[(did: Domain.DID, privateKeys: [Domain.StorableKey], alias: String?)], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getPeerDIDInfo(did: Domain.DID) -> AnyPublisher<(did: Domain.DID, privateKeys: [Domain.StorableKey], alias: String?)?, Error> {
        Just(nil).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getPeerDIDInfo(alias: String) -> AnyPublisher<[(did: Domain.DID, privateKeys: [Domain.StorableKey], alias: String?)], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getPeerDIDPrivateKeys(did: Domain.DID) -> AnyPublisher<[Domain.StorableKey]?, Error> {
        Just(nil).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getAllDIDs() -> AnyPublisher<[(did: Domain.DID, privateKeys: [Domain.StorableKey], alias: String?)], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getDIDInfo(did: Domain.DID) -> AnyPublisher<(did: Domain.DID, privateKeys: [Domain.StorableKey], alias: String?)?, Error> {
        Just(nil).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getDIDInfo(alias: String) -> AnyPublisher<[(did: Domain.DID, privateKeys: [Domain.StorableKey], alias: String?)], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getDIDPrivateKeys(did: Domain.DID) -> AnyPublisher<[Domain.StorableKey]?, Error> {
        Just(nil).tryMap { $0 }.eraseToAnyPublisher()
    }

    func getAllKeys() -> AnyPublisher<[StorableKey], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }

    func getKeyById(id: String) -> AnyPublisher<StorableKey?, Error> {
        Just(nil).tryMap { $0 }.eraseToAnyPublisher()
    }

    func getAllDidPairs() -> AnyPublisher<[Domain.DIDPair], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getPair(otherDID: Domain.DID) -> AnyPublisher<Domain.DIDPair?, Error> {
        Just(nil).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getPair(name: String) -> AnyPublisher<Domain.DIDPair?, Error> {
        Just(nil).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getPair(holderDID: Domain.DID) -> AnyPublisher<Domain.DIDPair?, Error> {
        Just(nil).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getAllMessages() -> AnyPublisher<[Domain.Message], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getAllMessages(did: Domain.DID) -> AnyPublisher<[Domain.Message], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getAllMessagesSent() -> AnyPublisher<[Domain.Message], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getAllMessagesReceived() -> AnyPublisher<[Domain.Message], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getAllMessagesSentTo(did: Domain.DID) -> AnyPublisher<[Domain.Message], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getAllMessagesReceivedFrom(did: Domain.DID) -> AnyPublisher<[Domain.Message], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getAllMessagesOfType(type: String, relatedWithDID: Domain.DID?) -> AnyPublisher<[Domain.Message], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getAllMessages(from: Domain.DID, to: Domain.DID) -> AnyPublisher<[Domain.Message], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getMessage(id: String) -> AnyPublisher<Domain.Message?, Error> {
        Just(nil).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getAllMediators() -> AnyPublisher<[(did: Domain.DID, routingDID: Domain.DID, mediatorDID: Domain.DID)], Error> {
        Just([]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getAllCredentials() -> AnyPublisher<[Domain.StorableCredential], Error> {
        self.credentials.publisher.collect().tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func getLinkSecret() -> AnyPublisher<StorableKey?, Error> {
        return Just(nil).tryMap { $0 }.eraseToAnyPublisher()
    }
}
