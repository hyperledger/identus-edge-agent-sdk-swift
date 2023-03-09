import Combine
import Domain
import Foundation

// MARK: DID High Level functionalities
public extension PrismAgent {
    /// Enumeration representing the type of DID used.
    enum DIDType {
        case prism
        case peer
    }

    /**
        This function will use the provided DID to sign a given message
        - Parameters:
        - did: The DID which will be used to sign the message.
        - message: The message to be signed
        - Throws:
        - PrismAgentError.cannotFindDIDKeyPairIndex If the DID provided has no register with the Agent
        - Any other errors thrown by the `getPrismDIDInfo` function or the `createKeyPair` function
        - Returns:
        - Signature: The signature of the message.
    */
    func signWith(did: DID, message: Data) async throws -> Signature {
        let seed = self.seed
        let apollo = self.apollo
        let pluto = self.pluto
        return try await pluto
            // First get DID info (KeyPathIndex in this case)
            .getPrismDIDInfo(did: did)
            .tryMap { [weak self] in
                // if no register is found throw an error
                guard let index = $0?.keyPairIndex else {
                    self?.logger.error(
                        message: """
Could not find key in storage please use Castor instead and provide the private key
"""
                    )
                    throw PrismAgentError.cannotFindDIDKeyPairIndex
                }
                // Re-Create the key pair to sign the message
                let keyPair = try apollo.createKeyPair(seed: seed, curve: .secp256k1(index: index))

                self?.logger.debug(message: "Signing message", metadata: [
                    .maskedMetadataByLevel(key: "messageB64", value: message.base64Encoded(), level: .debug)
                ])
                return try apollo.signMessage(privateKey: keyPair.privateKey, message: message)
            }
            .first()
            .await()
    }

    /// This method create a new Prism DID, that can be used to identify the agent and interact with other agents.
    /// - Parameters:
    ///   - keyPathIndex: key path index used to identify the DID
    ///   - alias: An alias that can be used to identify the DID
    ///   - services: an array of services associated to the DID
    /// - Returns: The new created DID
    func createNewPrismDID(
        keyPathIndex: Int? = nil,
        alias: String? = nil,
        services: [DIDDocument.Service] = []
    ) async throws -> DID {
        let seed = self.seed
        let apollo = self.apollo
        let castor = self.castor

        let (newDID, keyPathIndex) = try await pluto
            .getPrismLastKeyPairIndex()
            .tryMap { [weak self] in
                // If the user provided a key path index use it, if not use the last + 1
                let index = keyPathIndex ?? ($0 + 1)
                // Create the key pair
                let keyPair = try apollo.createKeyPair(seed: seed, curve: .secp256k1(index: index))
                let newDID = try castor.createPrismDID(masterPublicKey: keyPair.publicKey, services: services)
                self?.logger.debug(message: "Created new Prism DID", metadata: [
                    .maskedMetadataByLevel(key: "DID", value: newDID.string, level: .debug),
                    .maskedMetadataByLevel(key: "keyPathIndex", value: "\(index)", level: .debug)
                ])
                return (newDID, index)
            }
            .first()
            .await()

        try await registerPrismDID(did: newDID, keyPathIndex: keyPathIndex, alias: alias)
        return newDID
    }

    /// This method registers a Prism DID, that can be used to identify the agent and interact with other agents.
    /// - Parameters:
    ///   - did: the DID which will be registered.
    ///   - keyPathIndex: key path index used to identify the DID
    ///   - alias: An alias that can be used to identify the DID
    /// - Returns: The new created DID
    func registerPrismDID(
        did: DID,
        keyPathIndex: Int,
        alias: String? = nil
    ) async throws {
        logger.debug(message: "Register of DID in storage", metadata: [
            .maskedMetadataByLevel(key: "DID", value: did.string, level: .debug)
        ])

        try await pluto
            .storePrismDID(did: did, keyPairIndex: keyPathIndex, alias: alias)
            .first()
            .await()
    }

    /// This function creates a new Peer DID, stores it in pluto database and updates the mediator if requested.
    ///
    /// - Parameters:
    ///   - services: The services associated to the new DID.
    ///   - updateMediator: Indicates if the new DID should be added to the mediator's list. It will as well add the mediator service.
    /// - Returns: A new DID
    /// - Throws: PrismAgentError, if updateMediator is true and there is no mediator available or if storing the new DID failed
    func createNewPeerDID(
        services: [DIDDocument.Service] = [],
        alias: String? = "",
        updateMediator: Bool
    ) async throws -> DID {
        let keyAgreementKeyPair = try apollo.createKeyPair(seed: seed, curve: .x25519)
        let authenticationKeyPair = try apollo.createKeyPair(seed: seed, curve: .ed25519)

        let withServices: [DIDDocument.Service]
        if updateMediator, let routingDID = mediatorRoutingDID?.string {
            withServices = services + [.init(
                id: "#didcomm-1",
                type: ["DIDCommMessaging"],
                serviceEndpoint: [.init(
                    uri: routingDID
                )])]
        } else {
            withServices = services
        }

        let newDID = try castor.createPeerDID(
            keyAgreementKeyPair: keyAgreementKeyPair,
            authenticationKeyPair: authenticationKeyPair,
            services: withServices
        )

        logger.debug(message: "Created new Peer DID", metadata: [
            .maskedMetadataByLevel(key: "DID", value: newDID.string, level: .debug)
        ])

        try await registerPeerDID(
            did: newDID,
            privateKeys: [
                keyAgreementKeyPair.privateKey,
                authenticationKeyPair.privateKey
            ],
            alias: alias,
            updateMediator: updateMediator
        )

        return newDID
    }

    /// This function registers a Peer DID, stores it and his private key in pluto database and updates the mediator if requested.
    ///
    /// - Parameters:
    ///   - services: The services associated to the new DID.
    ///   - updateMediator: Indicates if the new DID should be added to the mediator's list.
    /// - Returns: A new DID
    /// - Throws: PrismAgentError, if updateMediator is true and there is no mediator available or if storing the new DID failed
    func registerPeerDID(
        did: DID,
        privateKeys: [PrivateKey],
        alias: String?,
        updateMediator: Bool
    ) async throws {
        if updateMediator {
            try await updateMediatorWithDID(did: did)
        }
        logger.debug(message: "Register of DID in storage", metadata: [
            .maskedMetadataByLevel(key: "DID", value: did.string, level: .debug)
        ])

        try await pluto
            .storePeerDID(
                did: did,
                privateKeys: privateKeys,
                alias: alias
            )
            .first()
            .await()
    }

    /// This function updates the mediator key list with a new DID.
    ///
    /// - Parameters:
    ///   - services: The services associated to the new DID.
    ///   - updateMediator: Indicates if the new DID should be added to the mediator's list.
    /// - Returns: A new DID
    /// - Throws: PrismAgentError, if updateMediator is true and there is no mediator available
    func updateMediatorWithDID(did: DID) async throws {
        logger.debug(message: "Update mediator key list with DID", metadata: [
            .maskedMetadataByLevel(key: "DID", value: did.string, level: .debug)
        ])

        try await mediationHandler.updateKeyListWithDIDs(dids: [did])
    }

    /// This function gets the DID information (alias) for a given DID
    ///
    /// - Parameter did: The DID for which the information is requested
    /// - Returns: A tuple containing the DID and the alias (if available), or nil if the DID method is not recognized
    /// - Throws: An error if there was a problem fetching the information
    func getDIDInfo(did: DID) async throws -> (did: DID, alias: String?)? {
        let pluto = self.pluto
        switch did.method {
        case "prism":
            return try await pluto
                .getPrismDIDInfo(did: did)
                .map {
                    $0.map { ($0.did, $0.alias) }
                }
                .first()
                .await()
        case "peer":
            return try await pluto
                .getPeerDIDInfo(did: did)
                .map {
                    $0.map { ($0.did, $0.alias) }
                }
                .first()
                .await()
        default:
            return nil
        }
    }

    /// This function registers a DID pair in the `pluto` store
    ///
    /// - Parameter pair: The DID pair to register
    /// - Throws: An error if there was a problem storing the pair
    func registerDIDPair(pair: DIDPair) async throws {
        try await pluto.storeDIDPair(pair: pair)
        .first()
        .await()
    }

    /// This function gets all the DID pairs from the `pluto` store
    /// 
    /// - Returns: A publisher that emits an array of `DIDPair` objects, or an error if there was a problem getting the pairs
    func getAllDIDPairs() -> AnyPublisher<[DIDPair], Error> {
        pluto.getAllDidPairs()
    }

    /// This function gets all the DID peers from the `pluto` store
    ///
    /// - Returns: A publisher that emits an array of tuples (`DID`, `String?`) objects, or an error if there was a problem getting the dids
    func getAllRegisteredPeerDIDs() -> AnyPublisher<[(did: DID, alias: String?)], Error> {
        pluto.getAllPeerDIDs()
            .map { $0.map { ($0.did, $0.alias) } }
            .eraseToAnyPublisher()
    }
}