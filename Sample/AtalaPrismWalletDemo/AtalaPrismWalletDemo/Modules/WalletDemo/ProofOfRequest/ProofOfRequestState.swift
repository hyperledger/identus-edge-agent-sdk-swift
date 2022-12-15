import Foundation
struct ProofOfRequestState {
    enum FlowStep {
        case loading
        case shareCredentials
        case confirm
        case error(DisplayError)
    }

    enum RequestedCredentials {
        case idCredential
        case universityDegree
        case proofOfEmployment
        case insurance
        case custom(String)
    }

    struct Contact {
        let text: String
//        let credentialsRequested: [RequestedCredentials]
    }

    struct Credential {
        let id: String
        let text: String
    }
}
