import Foundation

struct ChatViewState {
    struct Message: Identifiable, Hashable {
        var id: Date { date }
        let date: Date
        let text: String
        let sent: Bool
    }
}
