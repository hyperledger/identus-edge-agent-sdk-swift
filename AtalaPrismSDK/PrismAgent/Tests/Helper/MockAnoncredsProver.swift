import AnoncredsSwift
import Domain
import Foundation

struct MockProver {
    let did = "did:test:adsadiada"
    let linkSecret: Key
    let credDef: CredentialDefinition

    init(linkSecret: Key, credDef: CredentialDefinition) {
        self.linkSecret = linkSecret
        self.credDef = credDef
    }

    func createRequest(offer: CredentialOffer) throws -> (CredentialRequest, CredentialRequestMetadata) {
        let result = try Prover().createCredentialRequest(
            entropy: "did",
            proverDid: nil,
            credDef: credDef,
            linkSecret: try AnoncredsSwift.LinkSecret.newFromValue(valueString: linkSecret.raw.tryToString()),
            linkSecretId: "test",
            credentialOffer: offer
        )
        return (result.request, result.metadata)
    }
}
