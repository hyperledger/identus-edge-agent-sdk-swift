
final class CredentialTests: Feature {
    override func featureTitle() -> String {
        return "Receive verifiable credential"
    }
    
    func testReceiveOneCredential() async throws {
        let createConnection = Scenario(scenario: "Receive one verifiable credential")
        createConnection.when("Cloud Agent offers a credential")
        createConnection.then("Edge Agent should receive the credential")
        createConnection.when("Agent accepts the credential")
        createConnection.when("Cloud Agent should see the credential was accepted")
        createConnection.then("Edge Agent wait to receive 1 issued credentials")
        createConnection.then("Edge Agent process 1 issued credentials")
        try await createConnection.run()
    }
}
