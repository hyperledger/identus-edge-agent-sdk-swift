import Domain
@testable import PrismAgent
import XCTest

final class PrismAgentStartTests: XCTestCase {

    func testPrismAgentStart() async throws {
        let did = try DID(string: "did:peer:2.Ez6LScc4S6tTSf5PnB7tWAna8Ee2aL7z2nRgo6aCHQwLds3m4.Vz6MktCyutFBcZcAWBnE2shqqUQDyRdnvcwqMTPqWsGHMnHyT.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwOi8vcm9vdHNpZC1tZWRpYXRvcjo4MDAwIiwiYSI6WyJkaWRjb21tL3YyIl19")
        let agent = PrismAgent(mediatorServiceEnpoint: did)

        try await agent.start()
    }
}
