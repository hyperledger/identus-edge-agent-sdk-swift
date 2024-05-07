@testable import EdgeAgent
import Builders
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

//    func testLocal() async throws {
//        let example = PrismOnboardingInvitation.Body(
//            type: "https://atalaprism.io/did-request",
//            onboardEndpoint: "http://localhost:8070/onboard/fc16fa95-43e2-4313-a201-7bbca8d5641d",
//            from: "Goncalo Frade"
//        )
//
//        let jsonString = try String(data: JSONEncoder().encode(example), encoding: .utf8)!
//
//        let apollo = ApolloBuilder().build()
//        let castor = CastorBuilder(apollo: apollo).build()
//        let agent = EdgeAgent(
//            apollo: apollo,
//            castor: castor,
//            pluto: PlutoBuilder(setup: .init(coreDataSetup: .init(
//                modelPath: .storeName("PrismPluto"),
//                storeType: .memory
//            ))).build(),
//            mercury: MercuryBuilder(castor: castor).build()
//        )
//        let invitation = try await agent.parsePrismInvitation(str: jsonString)
//        do {
//            try await agent.acceptPrismInvitation(invitation: invitation)
//        } catch {
//            print(error)
//        }
//    }
}
