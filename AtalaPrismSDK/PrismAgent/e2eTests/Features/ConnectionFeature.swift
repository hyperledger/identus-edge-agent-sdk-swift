
final class ConnectionFeature: Feature {
    override func featureTitle() -> String {
        "Create connection"
    }
    
    override func featureDescription() -> String {
        "The Edge Agent should be able to create a connection to Open Enterprise Agent"
    }
    
    func testConnection() async throws {
        try await Scenario("Create connection between Cloud and Edge agents")
            .given("Cloud Agent has a connection invitation")
            .given("Cloud Agent shares invitation to Edge Agent")
            .when("Edge Agent connects through the invite")
            .then("Cloud Agent should have the connection status updated to 'ConnectionResponseSent'")
            .run()
    }
}
