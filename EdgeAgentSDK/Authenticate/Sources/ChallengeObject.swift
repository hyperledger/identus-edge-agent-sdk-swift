import Foundation

public struct ChallengeObject {
    public struct MissingFieldError: Error {}

    public static let versions = [1.0]
    public let challengedDID: String
    public let challenge: String
    public let challengerName: String
    public let challengerDID: String

    public init(
        challengedDID: String,
        challenge: String,
        challengerName: String,
        challengerDID: String
    ) {
        self.challengedDID = challengedDID
        self.challenge = challenge
        self.challengerName = challengerName
        self.challengerDID = challengerDID
    }

    public init(fromQueryItems: [URLQueryItem]) throws {
        guard
            let challengedDID = fromQueryItems
            .first(where: { $0.name == "challengedDID" })?.value,
            let challenge = fromQueryItems
            .first(where: { $0.name == "challenge" })?.value,
            let challengerDID = fromQueryItems
            .first(where: { $0.name == "challengerDID" })?.value,
            let challengerName = fromQueryItems
            .first(where: { $0.name == "challengerName" })?.value
        else { throw MissingFieldError() }

        self.init(
            challengedDID: challengedDID,
            challenge: challenge,
            challengerName: challengerName,
            challengerDID: challengerDID
        )
    }

    var queryItems: [URLQueryItem] {
        return [
            URLQueryItem(name: "challengedDID", value: challengedDID),
            URLQueryItem(name: "challenge", value: challenge),
            URLQueryItem(name: "challengerDID", value: challengerDID),
            URLQueryItem(name: "challengerName", value: challengerName)
        ]
    }
}
