import Domain
import Foundation

extension CastorImpl: Castor {
    public func parseDID(str: String) throws -> DID {
        try DIDParser(didString: str).parse()
    }

    public func createPrismDID(
        masterPublicKey: PublicKey,
        services: [DIDDocument.Service]
    ) throws -> DID {
        try CreatePrismDIDOperation(
            apollo: apollo,
            masterPublicKey: masterPublicKey,
            services: services
        ).compute()
    }

    public func createPeerDID(
        keyAgreementKeyPair: KeyPair,
        authenticationKeyPair: KeyPair,
        services: [DIDDocument.Service]
    ) throws -> DID {
        try CreatePeerDIDOperation(
            autenticationKeyPair: authenticationKeyPair,
            agreementKeyPair: keyAgreementKeyPair,
            services: services
        ).compute()
    }

    public func verifySignature(did: DID, challenge: Data, signature: Data) async throws -> Bool {
        let document = try await resolveDID(did: did)
        return verifySignature(document: document, challenge: challenge, signature: signature)
    }

    public func verifySignature(
        document: DIDDocument,
        challenge: Data,
        signature: Data
    ) -> Bool {
        return VerifySignatureOperation(
            apollo: apollo,
            document: document,
            challenge: challenge,
            signature: signature
        ).compute()
    }

    public func resolveDID(did: DID) async throws -> DIDDocument {
        logger.info(message: "Trying to resolve DID", metadata: [
            .maskedMetadataByLevel(key: "DID", value: did.string, level: .debug)
        ])
        guard
            let resolver = resolvers.first(where: { $0.method == did.method })
        else {
            logger.error(message: "No resolvers for DID method \(did.method)", metadata: [
                .maskedMetadataByLevel(key: "DID", value: did.string, level: .debug)
            ])
            throw CastorError.notPossibleToResolveDID
        }
        return try await resolver.resolve(did: did)
    }

    public func getEcnumbasis(did: DID, keyPair: KeyPair) throws -> String {
        logger.debug(message: "Getting ecnumbasis", metadata: [
            .maskedMetadataByLevel(key: "DID", value: did.string, level: .debug)
        ])
        return try CreatePeerDIDOperation(
            autenticationKeyPair: keyPair,
            agreementKeyPair: keyPair,
            services: []
        ).computeEcnumbasis(did: did, keyPair: keyPair)
    }
}
