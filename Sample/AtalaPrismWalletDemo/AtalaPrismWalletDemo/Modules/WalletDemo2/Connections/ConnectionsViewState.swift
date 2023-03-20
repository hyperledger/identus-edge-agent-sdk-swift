struct ConnectionsViewState {
    struct Connection: Identifiable {
        var id: String { hostDID + recipientDID }
        let hostDID: String
        let recipientDID: String
        let alias: String?
    }
}
