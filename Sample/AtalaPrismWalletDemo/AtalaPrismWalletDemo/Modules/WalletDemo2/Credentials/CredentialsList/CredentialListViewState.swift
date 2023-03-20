struct CredentialListViewState {
    struct Credential: Hashable {
        let credentialType: String
        let id: String
        let issuer: String
        let issuanceDate: String
        let context: [String]
        let type: [String]
    }
}
