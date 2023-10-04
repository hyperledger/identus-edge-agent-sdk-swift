import AnoncredsSwift
import Combine
import Core
import Domain
import Foundation

private struct Schema: Codable {
    let name: String
    let version: String
    let attrNames: [String]
    let issuerId: String
}

struct CreateAnoncredCredentialRequest {
    static func create(
        did: String,
        linkSecret: String,
        linkSecretId: String,
        offerData: Data,
        credentialDefinitionDownloader: Downloader
    ) async throws -> String {
        let linkSecretObj = try LinkSecret.newFromValue(valueString: linkSecret)
        let offer = try CredentialOffer(jsonString: String(data: offerData, encoding: .utf8)!)
        let credDefId = offer.getCredDefId()
        
        let credentialDefinitionData = try await credentialDefinitionDownloader.downloadFromEndpoint(urlOrDID: credDefId)
        let credentialDefinitionJson = try credentialDefinitionData.toString()

        let credentialDefinition = try CredentialDefinition(jsonString: credentialDefinitionJson)

        let def = try Prover().createCredentialRequest(
            entropy: did,
            proverDid: nil,
            credDef: credentialDefinition,
            linkSecret: linkSecretObj,
            linkSecretId: linkSecretId,
            credentialOffer: offer
        ).request.getJson()
        return def
    }
}
