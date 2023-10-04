import Foundation

struct CredentialDetailViewState {
    let issuer: String
    let claims: [String: String]
    let credentialDefinitionId: String?
    let schemaId: String?
}
