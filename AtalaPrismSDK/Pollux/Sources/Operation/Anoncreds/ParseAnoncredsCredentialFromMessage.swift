import AnoncredsSwift
import Domain
import Foundation

struct ParseAnoncredsCredentialFromMessage {
    static func parse(
        issuerCredentialData: Data,
        linkSecret: String,
        credentialDefinitionDownloader: Downloader,
        schemaDownloader: Downloader,
        thid: String,
        pluto: Pluto
    ) async throws -> AnoncredsCredentialStack {
        let domainCred = try JSONDecoder().decode(AnonCredential.self, from: issuerCredentialData)
        let credentialDefinitionData = try await credentialDefinitionDownloader
            .downloadFromEndpoint(urlOrDID: domainCred.credentialDefinitionId)
        let schemaData = try await schemaDownloader
            .downloadFromEndpoint(urlOrDID: domainCred.schemaId)

        guard let metadata = try await pluto.getAllCredentials()
            .first()
            .await()
            .first(where: { $0.storingId == thid })
        else {
            throw PolluxError.messageDoesntProvideEnoughInformation
        }

        let linkSecretObj = try LinkSecret.newFromValue(valueString: linkSecret)
        let credentialDefinitionJson = try credentialDefinitionData.toString()
        let credentialDefinition = try CredentialDefinition(jsonString: credentialDefinitionJson)

        let credentialMetadataJson = try metadata.credentialData.toString()
        let credentialMetadataObj = try CredentialRequestMetadata(jsonString: credentialMetadataJson)

        let credentialObj = try Credential(jsonString: issuerCredentialData.toString())

        let processedCredential = try Prover().processCredential(
            credential: credentialObj,
            credRequestMetadata: credentialMetadataObj,
            linkSecret: linkSecretObj,
            credDef: credentialDefinition,
            revRegDef: nil
        )

        let processedCredentialJson = try processedCredential.getJson().tryData(using: .utf8)
        let finalCredential = try JSONDecoder().decode(AnonCredential.self, from: processedCredentialJson)
        return AnoncredsCredentialStack(
            schema: try? JSONDecoder.didComm().decode(AnonCredentialSchema.self, from: schemaData),
            definition: try JSONDecoder.didComm().decode(AnonCredentialDefinition.self, from: credentialDefinitionData),
            credential: finalCredential
        )
    }
}
