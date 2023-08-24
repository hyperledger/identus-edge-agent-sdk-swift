import AnoncredsSwift
import Combine
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
        credentialDefinitions: AnyPublisher<[(id: String, json: String)], Error>
    ) async throws -> String {
        let linkSecret = try LinkSecret.newFromJson(jsonString: linkSecret)
        let offer = try CredentialOffer(jsonString: String(data: offerData, encoding: .utf8)!)
        let credDefId = offer.getCredDefId()
        
        let definition = try await credentialDefinitions
            .tryMap {
                try $0
                    .first { $0.id == credDefId.value }
                    .map { try CredentialDefinition(jsonString: $0.json) }
            }
            .first()
            .await()
        
        guard let definition else { throw UnknownError.somethingWentWrongError() }
        
        return try Prover().createCredentialRequest(
            entropy: nil,
            proverDid: did,
            credDef: definition,
            linkSecret: linkSecret,
            linkSecretId: linkSecretId,
            credentialOffer: offer
        ).request.getJson()
    }
}
