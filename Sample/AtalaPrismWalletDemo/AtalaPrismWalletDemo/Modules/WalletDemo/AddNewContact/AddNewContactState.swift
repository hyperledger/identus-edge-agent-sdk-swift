import Foundation

struct AddNewContactState {
    enum AddContacFlowStep {
        case getCode
        case getInfo
        case alreadyConnected
        case confirmConnection
        case error(DisplayError)
    }

    struct Contact {
        let text: String
    }
}
