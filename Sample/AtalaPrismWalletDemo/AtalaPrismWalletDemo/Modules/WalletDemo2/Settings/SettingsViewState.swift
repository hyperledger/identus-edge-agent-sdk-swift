import Foundation

struct SettingsViewState {
    enum Menu: String, Identifiable {
        case dids = "DIDs"
        case mediator = "Mediator"
        case backup = "Backup"

        var id: String {
            self.rawValue
        }
    }
}
