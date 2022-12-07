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
        guard
            let document = try await resolvers
                .first?
                .resolve(did: did)
        else { throw CastorError.notPossibleToResolveDID }
        return document
    }
}
