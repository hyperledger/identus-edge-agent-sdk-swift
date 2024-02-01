import Foundation

public struct VerificationMaterialBuilder {
    public enum VerificationRelationship {
        case authentication
        case assertion
        case keyAgreement
        case capabilityInvocation
        case capabilityDelegation
    }

    public let relationship: VerificationRelationship
    public let key: ExportableKey

    public init(relationship: VerificationRelationship, key: ExportableKey) {
        self.relationship = relationship
        self.key = key
    }
}

public protocol CastorPlugin {
    var method: String { get }

    func parseDID(str: String) throws -> DID

    func createDID(
        verificationMaterials: [VerificationMaterialBuilder],
        services: [DIDDocument.Service]
    ) throws -> DID

    func resolveDID(did: DID) async throws -> DIDDocument

    func verifySignature(
        did: DID,
        challenge: Data,
        signature: Data
    ) async throws -> Bool

    func verifySignature(
        document: DIDDocument,
        challenge: Data,
        signature: Data
    ) async throws -> Bool
}
