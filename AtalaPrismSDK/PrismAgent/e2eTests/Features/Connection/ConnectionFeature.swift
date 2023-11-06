import XCTest

final class ConnectTests: CucumberLite {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testConnection() async throws {
        let createConnection = Scenario(scenario: "Create connection between Cloud and Edge agents")
        createConnection.given("Cloud Agent has a connection invitation")
        createConnection.given("Cloud Agent shares invitation to Edge Agent")
        createConnection.when("When Edge Agent connects through the invite")
        createConnection.then("Cloud Agent should have the connection status updated to 'ConnectionResponseSent'")
        try await createConnection.run()
    }
    
    @Step("{} has a connection invitation")
    var cloudAgentHasAConnectionInvitation = { (cloudAgent: String) in
        let connection = try await CloudAgent.createConnection()
        asActor(cloudAgent).remember(key: "connectionId", value: connection.connectionId)
    }
    
    @Step("{} shares invitation to {}")
    var cloudAgentSharesInvitationToEdgeAgent = { (cloudAgent: String, edgeAgent: String) in
        let connectionId: String = asActor(cloudAgent).recall(key: "connectionId")
        asActor(edgeAgent).remember(key: "connectionId", value: connectionId)
    }
    
    @Step("{} connects through the invite")
    var edgeAgentConnectsThroughTheInvitate = { (edgeAgent: String) in
        var edge = try await EdgeAgent()
    }
    
    @Step("{} should have the connection status updated to '{}'")
    var cloudAgentShouldHaveTheConnectionStatusUpdatedToConnectionResponseSent = { (cloudAgent: String, status: String) in
//        let response = try await CloudAgent.client.getConnections(.init())
        print("GET", cloudAgent, "status should be", status)
    }
}
