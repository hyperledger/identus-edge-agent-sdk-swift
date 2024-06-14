import Foundation

struct PrismOnboardingInvitation {
    struct Body: Codable {
        let type: String
        let onboardEndpoint: String
        let from: String
    }

    let body: Body

    init(jsonString: String) throws {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw EdgeAgentError.invitationIsInvalidError
        }
        let object = try JSONDecoder.didComm().decode(Body.self, from: jsonData)
        guard object.type == ProtocolTypes.prismOnboarding.rawValue else {
            throw EdgeAgentError.unknownInvitationTypeError
        }
        self.body = object
    }
}
