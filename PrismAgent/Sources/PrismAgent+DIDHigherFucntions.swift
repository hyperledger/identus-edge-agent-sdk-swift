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
                let keyPair = apollo.createKeyPair(seed: seed, curve: .secp256k1(index: index))

                self?.logger.debug(message: "Signing message", metadata: [
                    .maskedMetadataByLevel(key: "messageB64", value: message.base64Encoded(), level: .debug)
                ])
                return apollo.signMessage(privateKey: keyPair.privateKey, message: message)
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
                let keyPair = apollo.createKeyPair(seed: seed, curve: .secp256k1(index: index))
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
    ///   - updateMediator: Indicates if the new DID should be added to the mediator's list.
    /// - Returns: A new DID
    /// - Throws: PrismAgentError, if updateMediator is true and there is no mediator available or if storing the new DID failed
    func createNewPeerDID(
        services: [DIDDocument.Service] = [],
        updateMediator: Bool
    ) async throws -> DID {
        let keyAgreementKeyPair = apollo.createKeyPair(seed: seed, curve: .x25519)
        let authenticationKeyPair = apollo.createKeyPair(seed: seed, curve: .ed25519)

        let newDID = try castor.createPeerDID(
            keyAgreementKeyPair: keyAgreementKeyPair,
            authenticationKeyPair: authenticationKeyPair,
            services: services
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
                privateKeys: privateKeys
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
}
