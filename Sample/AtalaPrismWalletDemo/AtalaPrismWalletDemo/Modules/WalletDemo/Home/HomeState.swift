import Foundation

struct HomeState {
    enum Notifications {
        case empty
        case new(Int)
    }

    struct Profile {
        let profileImage: Data
        let fullName: String
    }

    struct ActivityLog {
        enum ActivityType {
            case connected
            case received
            case shared
        }

        let activityType: ActivityType
        let infoText: String
        let name: String
        let dateFormatter: RelativeDateTimeFormatter
        let date: Date
    }
}
