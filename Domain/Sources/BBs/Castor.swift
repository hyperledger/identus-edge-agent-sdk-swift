import Foundation

public protocol Castor {
    func parseDID(str: String) throws -> DID
    func createPrismDID(
        masterPublicKey: PublicKey,
        services: [DIDDocument.Service]
    ) throws -> DID

    func resolveDID(did: DID) throws -> DIDDocument

    func verifySignature(
        did: DID,
        challenge: Data,
        signature: Data
    ) throws -> Bool

    func verifySignature(
        document: DIDDocument,
        challenge: Data,
        signature: Data
    ) throws -> Bool
}

extension Castor {
    func createPrismDID(
        masterPublicKey: PublicKey,
        services: [DIDDocument.Service] = []
    ) throws -> DID {
        try createPrismDID(masterPublicKey: masterPublicKey, services: services)
    }
}
