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

    func testConnectionlessPresentationParsing() async throws {
        let connectionLessPresentation = "eyJpZCI6IjViMjUwMjIzLWExNDItNDRmYi1hOWJkLWU1MjBlNGI0ZjQzMiIsInR5cGUiOiJodHRwczovL2RpZGNvbW0ub3JnL291dC1vZi1iYW5kLzIuMC9pbnZpdGF0aW9uIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNkV0hWQ1BFOHc0NWZETjM4aUh0ZFJ6WGkyTFNqQmRSUjRGTmNOUm12VkNKcy5WejZNa2Z2aUI5S1F1OGlnNVZpeG1HZHM3dmdMNmoyUXNOUGFybkZaanBNQ0E5aHpQLlNleUowSWpvaVpHMGlMQ0p6SWpwN0luVnlhU0k2SW1oMGRIQTZMeTh4T1RJdU1UWTRMakV1TXpjNk9EQTNNQzlrYVdSamIyMXRJaXdpY2lJNlcxMHNJbUVpT2xzaVpHbGtZMjl0YlM5Mk1pSmRmWDAiLCJib2R5Ijp7ImdvYWxfY29kZSI6InByZXNlbnQtdnAiLCJnb2FsIjoiUmVxdWVzdCBwcm9vZiBvZiB2YWNjaW5hdGlvbiBpbmZvcm1hdGlvbiIsImFjY2VwdCI6W119LCJhdHRhY2htZW50cyI6W3siaWQiOiIyYTZmOGM4NS05ZGE3LTRkMjQtOGRhNS0wYzliZDY5ZTBiMDEiLCJtZWRpYV90eXBlIjoiYXBwbGljYXRpb24vanNvbiIsImRhdGEiOnsianNvbiI6eyJpZCI6IjI1NTI5MTBiLWI0NmMtNDM3Yy1hNDdhLTlmODQ5OWI5ZTg0ZiIsInR5cGUiOiJodHRwczovL2RpZGNvbW0uYXRhbGFwcmlzbS5pby9wcmVzZW50LXByb29mLzMuMC9yZXF1ZXN0LXByZXNlbnRhdGlvbiIsImJvZHkiOnsiZ29hbF9jb2RlIjoiUmVxdWVzdCBQcm9vZiBQcmVzZW50YXRpb24iLCJ3aWxsX2NvbmZpcm0iOmZhbHNlLCJwcm9vZl90eXBlcyI6W119LCJhdHRhY2htZW50cyI6W3siaWQiOiJiYWJiNTJmMS05NDUyLTQzOGYtYjk3MC0yZDJjOTFmZTAyNGYiLCJtZWRpYV90eXBlIjoiYXBwbGljYXRpb24vanNvbiIsImRhdGEiOnsianNvbiI6eyJvcHRpb25zIjp7ImNoYWxsZW5nZSI6IjExYzkxNDkzLTAxYjMtNGM0ZC1hYzM2LWIzMzZiYWI1YmRkZiIsImRvbWFpbiI6Imh0dHBzOi8vcHJpc20tdmVyaWZpZXIuY29tIn0sInByZXNlbnRhdGlvbl9kZWZpbml0aW9uIjp7ImlkIjoiMGNmMzQ2ZDItYWY1Ny00Y2E1LTg2Y2EtYTA1NTE1NjZlYzZmIiwiaW5wdXRfZGVzY3JpcHRvcnMiOltdfX19LCJmb3JtYXQiOiJwcmlzbS9qd3QifV0sInRoaWQiOiI1YjI1MDIyMy1hMTQyLTQ0ZmItYTliZC1lNTIwZTRiNGY0MzIiLCJmcm9tIjoiZGlkOnBlZXI6Mi5FejZMU2RXSFZDUEU4dzQ1ZkROMzhpSHRkUnpYaTJMU2pCZFJSNEZOY05SbXZWQ0pzLlZ6Nk1rZnZpQjlLUXU4aWc1Vml4bUdkczd2Z0w2ajJRc05QYXJuRlpqcE1DQTloelAuU2V5SjBJam9pWkcwaUxDSnpJanA3SW5WeWFTSTZJbWgwZEhBNkx5OHhPVEl1TVRZNExqRXVNemM2T0RBM01DOWthV1JqYjIxdElpd2ljaUk2VzEwc0ltRWlPbHNpWkdsa1kyOXRiUzkyTWlKZGZYMCJ9fX1dLCJjcmVhdGVkX3RpbWUiOjE3MjQzMzkxNDQsImV4cGlyZXNfdGltZSI6MTcyNDMzOTQ0NH0="

        let agent = EdgeAgent(mediatorDID: .init(method: "peer", methodId: "test"))
        let result = try await agent.parseInvitation(str: connectionLessPresentation)
        switch result {
        case .connectionlessPresentation(let requestPresentation):
            break
        default:
            XCTFail("It should give a connectionless presentation request")
        }
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
