import Foundation

public struct SubmitedChallengeObject {
    public enum ChallengerIdentification {
        case did(String)
        case name(String)
    }

    public enum Response {
        case accept(signature: String)
        case refuse
    }

    public static let versions = [1.0]
    public let challengeObject: ChallengeObject
    public let response: Response

    public init(
        challengeObject: ChallengeObject,
        response: Response
    ) {
        self.challengeObject = challengeObject
        self.response = response
    }

    public init(fromQueryItems: [URLQueryItem]) throws {
        let response = fromQueryItems
            .first(where: { $0.name == "signature" })?
            .value.map { Response.accept(signature: $0) } ?? .refuse

        self.init(
            challengeObject: try ChallengeObject(fromQueryItems: fromQueryItems),
            response: response
        )
    }

    var queryItems: [URLQueryItem] {
        switch response {
        case let .accept(signature: signature):
            return challengeObject.queryItems + [
                URLQueryItem(name: "signature", value: signature)
            ]
        case .refuse:
            return challengeObject.queryItems
        }
    }
}
