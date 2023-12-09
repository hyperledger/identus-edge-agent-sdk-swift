import Foundation

class ConnectionWorkflow {
    static func cloudAgentIsConnectedToEdgeAgent(cloudAgent: Actor, edgeAgent: Actor) async throws{
        try await cloudAgentHasAConnectionInvitation(cloudAgent: cloudAgent)
        try await cloudAgentSharesInvitationToEdgeAgent(cloudAgent: cloudAgent, edgeAgent: edgeAgent)
        try await edgeAgentConnectsThroughTheInvite(edgeAgent: edgeAgent)
        try await cloudAgentShouldHaveTheConnectionStatusUpdatedToConnectionResponseSent(cloudAgent: cloudAgent, state: .ConnectionResponseSent)
    }
    
    static func cloudAgentHasAConnectionInvitation(cloudAgent: Actor) async throws {
        let ability = try cloudAgent.using(OpenEnterpriseAPI.self)
        let connection = try await ability.createConnection()
        cloudAgent.remember(key: "invitation", value: connection.invitation.invitationUrl)
        cloudAgent.remember(key: "connectionId", value: connection.connectionId)
    }
    
    static func cloudAgentSharesInvitationToEdgeAgent(cloudAgent: Actor, edgeAgent: Actor) async throws {
        let invitation: String = cloudAgent.recall(key: "invitation")
        edgeAgent.remember(key: "invitation", value: invitation)
    }
    
    static func edgeAgentConnectsThroughTheInvite(edgeAgent: Actor) async throws {
        let invitation: String = edgeAgent.recall(key: "invitation")
        let url = URL(string: invitation)!
        
        
        
        let oob = try edgeAgent.using(Sdk.self).parseOOBInvitation(url: url)
        try await edgeAgent.using(Sdk.self).acceptDIDCommInvitation(invitation: oob)
    }
    
    static func cloudAgentShouldHaveTheConnectionStatusUpdatedToConnectionResponseSent(cloudAgent: Actor, state: Components.Schemas.Connection.statePayload) async throws {
        try await Wait.until {
            let connectionId: String = cloudAgent.recall(key: "connectionId")
            let actualState = try await cloudAgent.using(OpenEnterpriseAPI.self).getConnection(connectionId).state
            return actualState == state
        }
    }
}
