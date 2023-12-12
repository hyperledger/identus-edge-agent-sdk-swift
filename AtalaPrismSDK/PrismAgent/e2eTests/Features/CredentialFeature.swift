
final class CredentialTests: Feature {
    override func featureTitle() -> String {
        "Receive verifiable credential"
    }
    
    override func featureDescription() -> String {
        "The Edge Agent should be able to receive a verifiable credential from Cloud Agent"
    }
    
    func testReceiveOneCredential() async throws {
        try await Scenario("Receive one verifiable credential")
            .given("Cloud Agent is connected to Edge Agent")
            .when("Cloud Agent offers a credential")
            .then("Edge Agent should receive the credential")
            .when("Edge Agent accepts the credential")
            .when("Cloud Agent should see the credential was accepted")
            .then("Edge Agent wait to receive 1 issued credentials")
            .then("Edge Agent process 1 issued credentials")
            .run()
    }
    
    func testReceiveMultipleCredentialsSequentially() async throws {
        try await Scenario("Receive multiple verifiable credentials sequentially")
            .given("Cloud Agent is connected to Edge Agent")
            .when("Edge Agent accepts 3 credential offer sequentially from Cloud Agent")
            .then("Cloud Agent should see all credentials were accepted")
            .and("Edge Agent wait to receive 3 issued credentials")
            .and("Edge Agent process 3 issued credentials")
            .run()
    }
    
    func testReceiveMultipleCredentialsAtOnce() async throws {
        try await Scenario("Receive multiple verifiable credentials at once")
            .given("Cloud Agent is connected to Edge Agent")
            .when("Edge Agent accepts 3 credentials offer at once from Cloud Agent")
            .then("Cloud Agent should see all credentials were accepted")
            .and("Edge Agent wait to receive 3 issued credentials")
            .and("Edge Agent process 3 issued credentials")
            .run()
    }
}
