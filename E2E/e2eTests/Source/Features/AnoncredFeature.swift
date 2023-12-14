import Foundation

class AnoncredFeature: Feature {
    override func featureTitle() -> String {
        "Receive anonymous credential"
    }
    
    override func featureDescription() -> String {
        "The Edge Agent should be able to receive an anonymous credential from Cloud Agent"
    }
    
    func testReceiveOneAnoncred() async throws {
        scenario = Scenario("Receive one anonymous credential")
            .given("Cloud Agent is connected to Edge Agent")
            .when("Cloud Agent offers an anonymous credential")
            .then("Edge Agent should receive the credential")
            .when("Edge Agent accepts the credential")
            .when("Cloud Agent should see the credential was accepted")
            .then("Edge Agent wait to receive 1 issued credentials")
            .then("Edge Agent process 1 issued credentials")
    }
}
