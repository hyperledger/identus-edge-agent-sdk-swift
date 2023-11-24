import Foundation

class ConnectionSteps: Steps {
    @Step("{} has a connection invitation")
    var cloudAgentHasAConnectionInvitation = { (cloudAgent: String) in
        let connection = try await CloudAgent.createConnection()
        asActor(cloudAgent).remember(key: "invitation", value: connection.invitation.invitationUrl)
        asActor(cloudAgent).remember(key: "connectionId", value: connection.connectionId)
    }
    
    @Step("{} shares invitation to {}")
    var cloudAgentSharesInvitationToEdgeAgent = { (cloudAgent: String, edgeAgent: String) in
        let invitation: String = asActor(cloudAgent).recall(key: "invitation")
        asActor(edgeAgent).remember(key: "invitation", value: invitation)
    }
    
    @Step("{} connects through the invite")
    var edgeAgentConnectsThroughTheInvitate = { (edgeAgent: String) in
        let invitation: String = asActor(edgeAgent).recall(key: "invitation")
        let url = URL(string: invitation)!
        let oob = try asActor(edgeAgent).with(ability: Sdk.self).getSdk().parseOOBInvitation(url: url)
        try await asActor(edgeAgent).with(ability: Sdk.self).getSdk().acceptDIDCommInvitation(invitation: oob)
    }
    
    @Step("{} should have the connection status updated to '{}'")
    var cloudAgentShouldHaveTheConnectionStatusUpdatedToConnectionResponseSent = { (cloudAgent: String, state: String) in
        try await Wait.until {
            let connectionId: String = asActor(cloudAgent).recall(key: "connectionId")
            let actualState = try await CloudAgent.getConnection(connectionId).state.rawValue
            return actualState == state
        }
    }
}
