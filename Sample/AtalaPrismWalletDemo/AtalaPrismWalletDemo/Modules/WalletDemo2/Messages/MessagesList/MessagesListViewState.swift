struct MessagesListViewState {
    struct Message: Identifiable, Hashable {
        let id: String
        let title: String
        let did: String?
        let received: Bool
    }
}
