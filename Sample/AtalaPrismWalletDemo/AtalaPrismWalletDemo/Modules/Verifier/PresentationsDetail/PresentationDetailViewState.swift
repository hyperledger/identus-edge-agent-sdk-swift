import Foundation

struct PresentationDetailViewState {
    struct Presentation {
        let id: String
        let name: String
        let to: String
        let claims: [Claim]
    }

    struct Claim {
        let name: String
        let type: String
        let value: String
    }

    struct ReceivedPresentation: Identifiable {
        let id: String
        let isVerified: Bool
        let error: [String]
    }
}
