@testable import PrismAgent
import XCTest

final class PrismOnboardingInvitationTests: XCTestCase {
    func testWhenValidJsonInvitationThenReturn() throws {
        let example = PrismOnboardingInvitation.Body(
            type: ProtocolTypes.prismOnboarding.rawValue,
            onboardEndpoint: "localhost:8080",
            from: "someone"
        )

        let jsonString = try String(data: JSONEncoder().encode(example), encoding: .utf8)!

        let invitation = try PrismOnboardingInvitation(jsonString: jsonString)

        XCTAssertEqual(invitation.body.from, example.from)
        XCTAssertEqual(invitation.body.onboardEndpoint, example.onboardEndpoint)
        XCTAssertEqual(invitation.body.type, example.type)
    }

    func testWhenInvalidTypeInvitationThenReturn() throws {
        let example = PrismOnboardingInvitation.Body(
            type: "wrong type",
            onboardEndpoint: "localhost:8080",
            from: "someone"
        )

        let jsonString = try String(data: JSONEncoder().encode(example), encoding: .utf8)!

        XCTAssertThrowsError(try PrismOnboardingInvitation(jsonString: jsonString))
    }
}
