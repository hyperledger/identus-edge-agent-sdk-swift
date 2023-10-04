struct CredentialListViewState {
    struct Credential: Hashable {
        let id: String
        let issuer: String
        let issuanceDate: String
        let type: String
    }
}
