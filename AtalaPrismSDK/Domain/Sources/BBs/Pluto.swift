import Combine
import Foundation

/// The Pluto protocol defines the set of storage operations that are used in the Atala PRISM architecture. It provides an interface for storage operations in a portable, storage-agnostic manner, allowing data to be stored and retrieved using a variety of storage solutions.
public protocol Pluto {
    /// Stores a PRISM DID and associated cryptographic key pair in the data store.
    /// - Parameters:
    ///   - did: The DID to store.
    ///   - keyPairIndex: The index of the key pair to associate with the DID.
    ///   - alias: An optional alias to associate with the DID.
    /// - Returns: A publisher that completes when the operation finishes.
    func storePrismDID(
        did: DID,
        keyPairIndex: Int,
        alias: String?
    ) -> AnyPublisher<Void, Error>

    /// Stores a peer DID and associated private keys in the data store.
    /// - Parameters:
    ///   - did: The DID to store.
    ///   - privateKeys: The private keys to associate with the DID.
    ///   - alias: An optional alias to associate with the DID.
    /// - Returns: A publisher that completes when the operation finishes.
    func storePeerDID(
        did: DID,
        privateKeys: [PrivateKey & StorableKey],
        alias: String?
    ) -> AnyPublisher<Void, Error>

    /// Stores a DID and associated private keys in the data store.
    /// - Parameters:
    ///   - did: The DID to store.
    ///   - privateKeys: The private keys to associate with the DID.
    ///   - alias: An optional alias to associate with the DID.
    /// - Returns: A publisher that completes when the operation finishes.
    func storeDID(
        did: DID,
        privateKeys: [PrivateKey & StorableKey],
        alias: String?
    ) -> AnyPublisher<Void, Error>


    /// Stores a DID pair in the data store.
    /// - Parameter pair: The DID pair to store.
    /// - Returns: A publisher that completes when the operation finishes.
    func storeDIDPair(pair: DIDPair) -> AnyPublisher<Void, Error>

    /// Stores a message in the data store.
    /// - Parameters:
    ///   - message: The message to store.
    ///   - direction: The direction of the message (incoming or outgoing).
    /// - Returns: A publisher that completes when the operation finishes.
    func storeMessage(
        message: Message,
        direction: Message.Direction
    ) -> AnyPublisher<Void, Error>

    /// Stores multiple messages in the data store.
    /// - Parameter messages: The messages to store.
    /// - Returns: A publisher that completes when the operation finishes.
    func storeMessages(
        messages: [(Message, Message.Direction)]
    ) -> AnyPublisher<Void, Error>

    /// Stores a mediator DID for a given peer DID and routing DID.
    /// - Parameters:
    ///   - peer: The peer DID.
    ///   - routingDID: The routing DID.
    ///   - mediatorDID: The mediator DID.
    /// - Returns: A publisher that completes when the operation finishes.
    func storeMediator(
        peer: DID,
        routingDID: DID,
        mediatorDID: DID
    ) -> AnyPublisher<Void, Error>

    /// Stores a verifiable credential in the data store.
    /// - Parameter credential: The credential to store.
    /// - Returns: A publisher that completes when the operation finishes.
    func storeCredential(
        credential: StorableCredential
    ) -> AnyPublisher<Void, Error>
    
    func storeLinkSecret(secret: String) -> AnyPublisher<Void, Error>

    /// Returns all stored PRISM DIDs, along with their associated key pair indices and aliases (if any).
    /// - Returns: A publisher that emits an array of tuples representing the stored PRISM DIDs, along with their associated key pair indices and aliases (if any).
    func getAllPrismDIDs() -> AnyPublisher<[(did: DID, keyPairIndex: Int, alias: String?)], Error>

    /// Returns the stored information for a given PRISM DID, including the associated key pair index and alias (if any).
    /// - Parameter did: The PRISM DID to retrieve information for.
    /// - Returns: A publisher that emits an optional tuple containing the stored information for the given PRISM DID.
    func getPrismDIDInfo(did: DID) -> AnyPublisher<(did: DID, keyPairIndex: Int, alias: String?)?, Error>

    /// Returns the stored information for all PRISM DIDs that have a given alias, including the associated DIDs and key pair indices.
    /// - Parameter alias: The alias to search for.
    /// - Returns: A publisher that emits an array of tuples containing the stored information for the PRISM DIDs that have the given alias.
    func getPrismDIDInfo(alias: String) -> AnyPublisher<[(did: DID, keyPairIndex: Int)], Error>

    /// Returns the key pair index associated with a given PRISM DID.
    /// - Parameter did: The PRISM DID to retrieve the key pair index for.
    /// - Returns: A publisher that emits an optional integer representing the key pair index associated with the given PRISM DID.
    func getPrismDIDKeyPairIndex(did: DID) -> AnyPublisher<Int?, Error>

    /// Returns the index of the last generated key pair for PRISM DIDs.
    /// - Returns: A publisher that emits an integer representing the index of the last generated key pair for PRISM DIDs.
    func getPrismLastKeyPairIndex() -> AnyPublisher<Int, Error>

    /// Returns all stored peer DIDs, along with their associated private keys and aliases (if any).
    /// - Returns: A publisher that emits an array of tuples representing the stored peer DIDs, along with their associated private keys and aliases (if any).
    func getAllPeerDIDs() -> AnyPublisher<[(did: DID, privateKeys: [PrivateKey], alias: String?)], Error>

    /// Returns the stored information for a given peer DID, including the associated private keys and alias (if any).
    /// - Parameter did: The peer DID to retrieve information for.
    /// - Returns: A publisher that emits an optional tuple containing the stored information for the given peer DID.
    func getPeerDIDInfo(did: DID) -> AnyPublisher<(did: DID, privateKeys: [PrivateKey], alias: String?)?, Error>

    /// Returns the stored information for all peer DIDs that have a given alias, including the associated DIDs and private keys.
    /// - Parameter alias: The alias to search for.
    /// - Returns: A publisher that emits an array of tuples containing the stored information for the peer DIDs that have the given alias.
    func getPeerDIDInfo(alias: String) -> AnyPublisher<[(did: DID, privateKeys: [PrivateKey], alias: String?)], Error>

    /// Returns the private keys associated with a given peer DID.
    /// - Parameter did: The peer DID to retrieve the private keys for.
    /// - Returns: A publisher that emits an optional array of private keys associated with the given peer DID.
    func getPeerDIDPrivateKeys(did: DID) -> AnyPublisher<[PrivateKey]?, Error>

    /// Returns all stored peer DIDs, along with their associated private keys and aliases (if any).
    /// - Returns: A publisher that emits an array of tuples representing the stored peer DIDs, along with their associated private keys and aliases (if any).
    func getAllDIDs() -> AnyPublisher<[(did: DID, privateKeys: [PrivateKey], alias: String?)], Error>

    /// Returns the stored information for a given peer DID, including the associated private keys and alias (if any).
    /// - Parameter did: The peer DID to retrieve information for.
    /// - Returns: A publisher that emits an optional tuple containing the stored information for the given peer DID.
    func getDIDInfo(did: DID) -> AnyPublisher<(did: DID, privateKeys: [PrivateKey], alias: String?)?, Error>

    /// Returns the stored information for all peer DIDs that have a given alias, including the associated DIDs and private keys.
    /// - Parameter alias: The alias to search for.
    /// - Returns: A publisher that emits an array of tuples containing the stored information for the peer DIDs that have the given alias.
    func getDIDInfo(alias: String) -> AnyPublisher<[(did: DID, privateKeys: [PrivateKey], alias: String?)], Error>

    /// Returns the private keys associated with a given peer DID.
    /// - Parameter did: The peer DID to retrieve the private keys for.
    /// - Returns: A publisher that emits an optional array of private keys associated with the given peer DID.
    func getDIDPrivateKeys(did: DID) -> AnyPublisher<[PrivateKey]?, Error>

    /// Returns all stored DID pairs.
    /// - Returns: A publisher that emits an array of DID pairs.
    func getAllDidPairs() -> AnyPublisher<[DIDPair], Error>

    /// Returns the stored DID pair that includes a given DID.
    /// - Parameter otherDID: The DID to search for.
    /// - Returns: A publisher that emits an optional DID pair that includes the given DID.
    func getPair(otherDID: DID) -> AnyPublisher<DIDPair?, Error>

    /// Returns the stored DID pair that has a given name.
    /// - Parameter name: The name to search for.
    /// - Returns: A publisher that emits an optional DID pair that has the given name.
    func getPair(name: String) -> AnyPublisher<DIDPair?, Error>

    /// Returns the stored DID pair that includes a given holder DID.
    /// - Parameter holderDID: The holder DID to search for.
    /// - Returns: A publisher that emits an optional DID pair that includes the given holder DID.
    func getPair(holderDID: DID) -> AnyPublisher<DIDPair?, Error>

    /// Returns all stored messages.
    /// - Returns: A publisher that emits an array of messages.
    func getAllMessages() -> AnyPublisher<[Message], Error>

    /// Returns all stored messages that are associated with a given DID.
    /// - Parameter did: The DID to search for.
    /// - Returns: A publisher that emits an array of messages that are associated with the given DID.
    func getAllMessages(did: DID) -> AnyPublisher<[Message], Error>

    /// Returns all stored messages that were sent.
    /// - Returns: A publisher that emits an array of messages that were sent.
    func getAllMessagesSent() -> AnyPublisher<[Message], Error>

    /// Returns all stored messages that were received.
    /// - Returns: A publisher that emits an array of messages that were received.
    func getAllMessagesReceived() -> AnyPublisher<[Message], Error>

    /// Returns all stored messages that were sent to a given DID.
    /// - Parameter did: The DID to search for.
    /// - Returns: A publisher that emits an array of messages that were sent to the given DID.
    func getAllMessagesSentTo(did: DID) -> AnyPublisher<[Message], Error>

    /// Returns all stored messages that were received from a given DID.
    /// - Parameter did: The DID to search for.
    /// - Returns: A publisher that emits an array of messages that were received from the given DID.
    func getAllMessagesReceivedFrom(did: DID) -> AnyPublisher<[Message], Error>

    /// Returns all stored messages of a given type that are related to a given DID.
    /// - Parameters:
    ///   - type: The type of message to search for.
    ///   - relatedWithDID: The DID to search for.
    /// - Returns: A publisher that emits an array of messages of the given type that are related to the given DID.
    func getAllMessagesOfType(type: String, relatedWithDID: DID?) -> AnyPublisher<[Message], Error>

    /// Returns all stored messages that were sent from one DID to another.
    /// - Parameters:
    ///   - from: The sender DID to search for.
    ///   - to: The recipient DID to search for.
    /// - Returns: A publisher that emits an array of messages that were sent from the given sender DID to the given recipient DID.
    func getAllMessages(from: DID, to: DID) -> AnyPublisher<[Message], Error>

    /// Returns the stored message with the given ID.
    /// - Parameter id: The ID of the message to retrieve.
    /// - Returns: A publisher that emits an optional message with the given ID.
    func getMessage(id: String) -> AnyPublisher<Message?, Error>

    /// Returns all stored mediators, along with their associated routing DIDs and mediator DIDs.
    /// - Returns: A publisher that emits an array of tuples representing the stored mediators, along with their associated routing DIDs and mediator DIDs.
    func getAllMediators() -> AnyPublisher<[(did: DID, routingDID: DID, mediatorDID: DID)], Error>

    /// Returns all stored verifiable credentials.
    /// - Returns: A publisher that emits an array of stored verifiable credentials.
    func getAllCredentials() -> AnyPublisher<[StorableCredential], Error>
    
    func getLinkSecret() -> AnyPublisher<[String], Error>
}
