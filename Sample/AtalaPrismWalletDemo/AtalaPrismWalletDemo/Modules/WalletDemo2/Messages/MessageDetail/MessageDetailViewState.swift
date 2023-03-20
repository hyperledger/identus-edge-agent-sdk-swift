struct MessageDetailViewState {
    struct CommonDetail {
        let id: String
        let type: String
        let title: String
        let from: String?
        let to: String?
        let bodyString: String?
        let thid: String?
        let didRespond: Bool
    }

    enum SpecificDetail {
        case finishedThreads
        case acceptRefuse
        case credentialDomainChallenge(domain: String, challenge: String)
    }

    struct Message {
        let id: String
        let title: String
    }

    struct Credential {
        let id: String
        let title: String
    }

    let common: CommonDetail
    let specific: SpecificDetail
}
