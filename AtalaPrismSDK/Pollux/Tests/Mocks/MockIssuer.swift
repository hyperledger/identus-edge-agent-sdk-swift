import AnoncredsSwift
import Domain
import Foundation

struct MockIssuer {

    let issuer = "did:web:asadadada"
    let linkSecret: LinkSecret
    let schema: Schema
    let credDef: CredentialDefinition
    let credDefPriv: CredentialDefinitionPrivate
    let credDefCorrProof: CredentialKeyCorrectnessProof

    init() {
        self.linkSecret = try! LinkSecret.newFromValue(valueString: "36590588636589688587165354116254517405509622321561684934488049104990967858487")

        self.schema = try! Issuer().createSchema(
            schemaName: "Test",
            schemaVersion: "1.0.0",
            issuerId: issuer,
            attrNames: ["Test"]
        )

        let credDef = try! Issuer().createCredentialDefinition(
            schemaId: "http://localhost:8000/schemas/test",
            schema: schema,
            issuerId: issuer,
            tag: "test",
            signatureType: .cl,
            config: .init(supportRevocation: false)
        )

        self.credDef = credDef.credentialDefinition
        self.credDefPriv = credDef.credentialDefinitionPrivate
        self.credDefCorrProof = credDef.credentialKeyCorrectnessProof

        print("IssuerSecret: \(try! linkSecret.getValue())")

        print("credDef")
        print(try! credDef.credentialDefinition.getJson())
    }

    func createOffer() throws -> CredentialOffer {
        try Issuer().createCredentialOffer(
            schemaId: "http://localhost:8000/schemas/test",
            credDefId: "http://localhost:8000/definitions/test",
            correctnessProof: credDefCorrProof
        )
    }

    func createOfferMessage() throws -> Message {
        let offer = try createOffer().getJson()

        return Message(
            piuri: "https://didcomm.org/issue-credential/3.0/offer-credential",
            body: Data(),
            attachments: [
                .init(
                    id: "test1",
                    mediaType: nil,
                    data: AttachmentBase64(base64: offer.data(using: .utf8)!.base64EncodedString()),
                    filename: nil,
                    format: "anoncreds/credential-offer@v1.0",
                    lastmodTime: nil,
                    byteCount: nil,
                    description: nil
                )
            ]
        )
    }

    func issueCredential(
        offer: CredentialOffer,
        request: CredentialRequest
    ) throws -> Message {
        let issued = try Issuer().createCredential(
            credDef: credDef,
            credDefPrivate: credDefPriv,
            credOffer: offer,
            credRequest: request,
            credValues: [.init(raw: "test", encoded: "test")],
            revRegId: nil,
            revStatusList: nil,
            revocationConfig: nil
        ).getJson()

        return Message(
            piuri: "https://didcomm.org/issue-credential/3.0/issue-credential",
            body: Data(),
            attachments: [
                .init(
                    id: "test1",
                    mediaType: nil,
                    data: AttachmentBase64(base64: issued.data(using: .utf8)!.base64EncodedString()),
                    filename: nil,
                    format: "anoncreds/credential@v1.0",
                    lastmodTime: nil,
                    byteCount: nil,
                    description: nil
                )
            ]
        )
    }
}
