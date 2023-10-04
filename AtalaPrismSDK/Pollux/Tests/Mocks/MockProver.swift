import AnoncredsSwift
import Foundation

struct MockProver {
    let did = "did:test:adsadiada"
    let linkSecret: LinkSecret
    let credDef: CredentialDefinition

    init(linkSecret: LinkSecret, credDef: CredentialDefinition) {
        self.linkSecret = linkSecret
        self.credDef = credDef
    }

    func createRequest(offer: CredentialOffer) throws -> (CredentialRequest, CredentialRequestMetadata) {
        let result = try Prover().createCredentialRequest(
            entropy: "did",
            proverDid: nil,
            credDef: credDef,
            linkSecret: linkSecret,
            linkSecretId: "test",
            credentialOffer: offer
        )
        return (result.request, result.metadata)
    }
}
