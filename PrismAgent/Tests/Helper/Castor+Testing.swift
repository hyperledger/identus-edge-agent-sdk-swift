import Domain
import Foundation

struct CastorStub: Castor {
    var throwParseDIDError: Error?
    var parseDIDResponse: DID!
    var throwCreateDIDError: Error?
    var createDIDResponse: DID!
    var throwResolveDIDError: Error?
    var resolveDIDResponse: DIDDocument!
    var throwVerifySignatureError: Error?
    var verifySignatureResponse = true

    func parseDID(str: String) throws -> DID {
        guard throwParseDIDError == nil else { throw throwParseDIDError! }
        return parseDIDResponse
    }

    func createPrismDID(masterPublicKey: PublicKey, services: [DIDDocument.Service]) throws -> DID {
        guard throwCreateDIDError == nil else { throw throwCreateDIDError! }
        return createDIDResponse
    }

    func createPeerDID(
        keyAgreementKeyPair: KeyPair,
        authenticationKeyPair: KeyPair,
        services: [DIDDocument.Service]
    ) throws -> DID {
        guard throwCreateDIDError == nil else { throw throwCreateDIDError! }
        return createDIDResponse
    }

    func resolveDID(did: DID) throws -> DIDDocument {
        guard throwResolveDIDError == nil else { throw throwResolveDIDError! }
        return resolveDIDResponse
    }

    func verifySignature(did: DID, challenge: Data, signature: Data) throws -> Bool {
        guard throwVerifySignatureError == nil else { throw throwVerifySignatureError! }
        return verifySignatureResponse
    }

    func verifySignature(document: DIDDocument, challenge: Data, signature: Data) throws -> Bool {
        guard throwVerifySignatureError == nil else { throw throwVerifySignatureError! }
        return verifySignatureResponse
    }
}
