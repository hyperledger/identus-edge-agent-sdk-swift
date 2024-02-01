import Core
import Domain
import Foundation

public struct PeerDIDPlugin: CastorPlugin {
    let logger: PrismLogger
    let apollo: Apollo
    public let method = "peer"

    public init(
        logger: PrismLogger = PrismLogger(category: .castor),
        apollo: Apollo
    ) {
        self.logger = logger
        self.apollo = apollo
    }

    public func parseDID(str: String) throws -> DID {
        try DID(string: str)
    }

    public func createDID(
        verificationMaterials: [VerificationMaterialBuilder],
        services: [DIDDocument.Service]
    ) throws -> DID {
        try CreatePeerDIDOperation(
            // This would change so we create X number of public keys all target for the specific verification material, but thats a implementation detail inside the Plugins
            autenticationPublicKey: verificationMaterials.first { $0.relationship == .authentication }!.key,
            agreementPublicKey: verificationMaterials.first { $0.relationship == .keyAgreement }!.key,
            services: services
        ).compute()
    }

    public func resolveDID(did: DID) async throws -> DIDDocument {
        try await PeerDIDResolver().resolve(did: did)
    }

    public func verifySignature(did: DID, challenge: Data, signature: Data) async throws -> Bool {
        let document = try await resolveDID(did: did)
        return try await verifySignature(
            document: document,
            challenge: challenge,
            signature: signature
        )
    }

    public func verifySignature(document: DIDDocument, challenge: Data, signature: Data) async throws -> Bool {
        return try await VerifyDIDSignatureOperation(
            apollo: apollo,
            document: document,
            challenge: challenge,
            signature: signature
        ).compute()
    }
}
