import AnoncredsSwift
import Domain
import Foundation

struct ParseAnoncredsCredentialFromMessage {
    static func parse(
        issuerCredentialData: Data,
        linkSecret: String,
        credentialDefinitionDownloader: Downloader
    ) async throws -> AnoncredsCredentialStack {
        let domainCred = try JSONDecoder().decode(AnonCredential.self, from: issuerCredentialData)
        
        let credentialDefinitionData = try await credentialDefinitionDownloader
            .downloadFromEndpoint(urlOrDID: domainCred.credentialDefinitionId)
        
        return AnoncredsCredentialStack(
            definition: try JSONDecoder.didComm().decode(AnonCredentialDefinition.self, from: credentialDefinitionData),
            credential: domainCred
        )
    }
}
