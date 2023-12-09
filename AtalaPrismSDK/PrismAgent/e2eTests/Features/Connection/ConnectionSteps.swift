import Foundation

class ConnectionSteps: Steps {    
    @Step("{actor} is connected to {actor}")
    var cloudAgentIsConnectedToEdgeAgent = { (cloudAgent: Actor, edgeAgent: Actor) in
        try await ConnectionWorkflow.cloudAgentIsConnectedToEdgeAgent(cloudAgent: cloudAgent, edgeAgent: edgeAgent)
    }
    
    @Step("{actor} has a connection invitation")
    var cloudAgentHasAConnectionInvitation = { (cloudAgent: Actor) in
        try await ConnectionWorkflow.cloudAgentHasAConnectionInvitation(cloudAgent: cloudAgent)
    }
    
    @Step("{actor} shares invitation to {actor}")
    var cloudAgentSharesInvitationToEdgeAgent = { (cloudAgent: Actor, edgeAgent: Actor) in
        try await ConnectionWorkflow.cloudAgentSharesInvitationToEdgeAgent(cloudAgent: cloudAgent, edgeAgent: edgeAgent)
    }
    
    @Step("{actor} connects through the invite")
    var edgeAgentConnectsThroughTheInvite = { (edgeAgent: Actor) in
        try await ConnectionWorkflow.edgeAgentConnectsThroughTheInvite(edgeAgent: edgeAgent)
    }
    
    @Step("{actor} should have the connection status updated to '{}'")
    var cloudAgentShouldHaveTheConnectionStatusUpdatedToConnectionResponseSent = { (cloudAgent: Actor, state: String) in
        try await ConnectionWorkflow.cloudAgentShouldHaveTheConnectionStatusUpdatedToConnectionResponseSent(cloudAgent: cloudAgent, state: .ConnectionResponseSent)
    }
}
