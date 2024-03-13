import Domain
import Foundation

struct CreatePresentationViewState {
    enum CredentialType: String, CaseIterable, Identifiable {
        case jwt = "JWT"
        case anoncreds = "Anoncreds"

        var id: String { self.rawValue }
    }

    struct JWTClaim {
        var name: String = ""
        var type: String = ""
        var const: String = ""
        var pattern: String = ""
        var paths: [String] = []
        var format: String = ""
        var required: Bool = false
    }

    struct AnoncredsClaim {
        var name: String = ""
        var predicate: String = ""
    }

    struct Connection: Identifiable, Hashable {
        var id: String { recipientDID.string }

        var alias: String = ""
        var hostDID: DID
        var recipientDID: DID

        func hash(into hasher: inout Hasher) {
            hasher.combine(hostDID.string)
            hasher.combine(recipientDID.string)
        }
    }
}
