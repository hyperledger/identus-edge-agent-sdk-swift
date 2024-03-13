import Foundation

struct PresentationsViewState {
    struct Presentation {
        enum State {
            case sent
            case verified
            case failedVerification
        }

        let id: String
        let name: String
        let to: String
    }
}
