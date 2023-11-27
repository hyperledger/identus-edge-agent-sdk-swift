import AnoncredsSwift
import Domain
import Foundation

struct AnoncredsPresentation {
    func createPresentation(
        stack: AnoncredsCredentialStack,
        request: String,
        linkSecret: String,
        attributes: [String: Bool],
        predicates: [String]
    ) throws -> String {
        let linkSecret = try LinkSecret.newFromValue(valueString: linkSecret)
        let request = try PresentationRequest(jsonString: request)
        let credentialRequest = CredentialRequests(
            credential: try stack.credential.getAnoncred(),
            requestedAttribute: attributes.map {
                .init(referent: $0.key, revealed: $0.value)
            },
            requestedPredicate: predicates.map { .init(referent: $0) }
        )

        let credential = stack.credential
        let schema = Schema.init(
            name: stack.schema.name,
            version: stack.schema.version,
            attrNames: AttributeNames(stack.schema.attrNames),
            issuerId: stack.schema.issuerId
        )

        let credentialDefinition = try stack.definition.getAnoncred()
        return try Prover().createPresentation(
            presentationRequest: request,
            credentials: [credentialRequest],
            selfAttested: [:],
            linkSecret: linkSecret,
            schemas: [credential.schemaId: schema],
            credentialDefinitions: [credential.credentialDefinitionId: credentialDefinition]
        ).getJson()
    }
}
