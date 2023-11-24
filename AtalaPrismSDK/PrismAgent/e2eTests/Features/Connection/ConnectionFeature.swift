
final class ConnectionFeature: Feature {
    func testConnection() async throws {
        let createConnection = Scenario(scenario: "Create connection between Cloud and Edge agents")
        createConnection.given("Cloud Agent has a connection invitation")
        createConnection.given("Cloud Agent shares invitation to Edge Agent")
        createConnection.when("Edge Agent connects through the invite")
        createConnection.then("Cloud Agent should have the connection status updated to 'ConnectionResponseSent'")
        try await createConnection.run()
    }
}
