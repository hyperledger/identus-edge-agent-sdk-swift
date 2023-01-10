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
        return try await withCheckedThrowingContinuation { continuation in
            pluto
                // First get DID info (KeyPathIndex in this case)
                .getPrismDIDInfo(did: did)
                .tryMap {
                    // if no register is found throw an error
                    guard let index = $0?.keyPairIndex else { throw PrismAgentError.cannotFindDIDKeyPairIndex }
                    // Re-Create the key pair to sign the message
                    let keyPair = apollo.createKeyPair(seed: seed, curve: .secp256k1(index: index))
                    return apollo.signMessage(privateKey: keyPair.privateKey, message: message)
                }
                .first()
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: {
                    continuation.resume(returning: $0)
                })
                .store(in: &self.cancellables)
        }
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
        let pluto = self.pluto

        return try await withCheckedThrowingContinuation { continuation in
            pluto
                // Retrieve the last keyPath index used
                .getPrismLastKeyPairIndex()
                .tryMap {
                    // If the user provided a key path index use it, if not use the last + 1
                    let index = keyPathIndex ?? ($0 + 1)
                    // Create the key pair
                    let keyPair = apollo.createKeyPair(seed: seed, curve: .secp256k1(index: index))
                    let newDID = try castor.createPrismDID(masterPublicKey: keyPair.publicKey, services: services)
                    return (newDID, index, alias)
                }
                .flatMap { did, index, alias in
                    // Store the did and its index path
                    return pluto
                        .storePrismDID(did: did, keyPairIndex: index, alias: alias)
                        .map { did }
                }
                .first()
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: {
                    continuation.resume(returning: $0)
                })
                .store(in: &self.cancellables)
        }
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
        let apollo = self.apollo
        let castor = self.castor
        let pluto = self.pluto

        let keyAgreementKeyPair = apollo.createKeyPair(seed: seed, curve: .x25519)
        let authenticationKeyPair = apollo.createKeyPair(seed: seed, curve: .ed25519)

        let did = try castor.createPeerDID(
            keyAgreementKeyPair: keyAgreementKeyPair,
            authenticationKeyPair: authenticationKeyPair,
            services: services
        )

        if updateMediator {
            guard let mediator = connectionManager.mediator else {
                throw PrismAgentError.noMediatorAvailableError
            }
            let keyListUpdateMessage = try MediationKeysUpdateList(
                from: mediator.peerDID,
                to: mediator.mediatorDID,
                recipientDid: did
            ).makeMessage()

            try await mercury.sendMessage(msg: keyListUpdateMessage)
        }

        return try await withCheckedThrowingContinuation { continuation in
            pluto
                .storePeerDID(
                    did: did,
                    privateKeys: [
                        keyAgreementKeyPair.privateKey,
                        authenticationKeyPair.privateKey
                    ])
                .map { did }
                .first()
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: {
                    continuation.resume(returning: $0)
                })
                .store(in: &self.cancellables)
        }
    }
}
