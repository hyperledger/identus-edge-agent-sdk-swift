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

public struct StorableCredentialRequestMetadata: StorableCredential {
    public let metadataJson: Data
    public let storingId: String
    public var recoveryId: String { "anoncreds+metadata"}
    public var credentialData: Data { metadataJson }
    public var queryIssuer: String? { nil }
    public var querySubject: String? { nil }
    public var queryCredentialCreated: Date? { nil }
    public var queryCredentialUpdated: Date? { nil }
    public var queryCredentialSchema: String? { nil }
    public var queryValidUntil: Date? { nil }
    public var queryRevoked: Bool? { nil }
    public var queryAvailableClaims: [String] { [] }

    public init(metadataJson: Data, storingId: String) {
        self.metadataJson = metadataJson
        self.storingId = storingId
    }
}

struct CreateAnoncredCredentialRequest {
    static func create(
        did: String,
        linkSecret: String,
        linkSecretId: String,
        offerData: Data,
        credentialDefinitionDownloader: Downloader,
        thid: String,
        pluto: Pluto
    ) async throws -> String {
        let linkSecretObj = try LinkSecret.newFromValue(valueString: linkSecret)
        let offer = try CredentialOffer(jsonString: offerData.tryToString())
        let credDefId = offer.getCredDefId()

        let credentialDefinitionData = try await credentialDefinitionDownloader.downloadFromEndpoint(urlOrDID: credDefId)
        let credentialDefinitionJson = try credentialDefinitionData.toString()
        let credentialDefinition = try CredentialDefinition(jsonString: credentialDefinitionJson)

        let requestData = try Prover().createCredentialRequest(
            entropy: did,
            proverDid: nil,
            credDef: credentialDefinition,
            linkSecret: linkSecretObj,
            linkSecretId: linkSecretId,
            credentialOffer: offer
        )

        guard
            let metadata = try requestData.metadata.getJson().data(using: .utf8)
        else {
            throw CommonError.invalidCoding(message: "Could not decode to data")
        }

        let storableMetadata = StorableCredentialRequestMetadata(metadataJson: metadata, storingId: thid)

        try await pluto.storeCredential(credential: storableMetadata).first().await()

        return try requestData.request.getJson()
    }
}
