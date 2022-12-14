import Foundation

struct CredentialsListState {
    struct Credential: Identifiable {
        enum Icon {
            case data(Data)
            case name(String)
        }

        let id: String
        let icon: Icon
        let title: String
        let subtitle: String
    }
}
