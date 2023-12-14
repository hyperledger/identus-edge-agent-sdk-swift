import Foundation

class CloudAgentWorkflow {
    static func isConnectedToEdgeAgent(cloudAgent: Actor, edgeAgent: Actor) async throws{
        try await hasAConnectionInvitation(cloudAgent: cloudAgent)
        try await sharesInvitationToEdgeAgent(cloudAgent: cloudAgent, edgeAgent: edgeAgent)
        try await EdgeAgentWorkflow.connectsThroughTheInvite(edgeAgent: edgeAgent)
        try await shouldHaveTheConnectionStatusUpdated(cloudAgent: cloudAgent, state: .ConnectionResponseSent)
    }
    
    static func hasAConnectionInvitation(cloudAgent: Actor) async throws {
        let ability = try cloudAgent.using(OpenEnterpriseAPI.self)
        let connection = try await ability.createConnection()
        cloudAgent.remember(key: "invitation", value: connection.invitation.invitationUrl)
        cloudAgent.remember(key: "connectionId", value: connection.connectionId)
    }
    
    static func sharesInvitationToEdgeAgent(cloudAgent: Actor, edgeAgent: Actor) async throws {
        let invitation: String = cloudAgent.recall(key: "invitation")
        edgeAgent.remember(key: "invitation", value: invitation)
    }
    
    static func shouldHaveTheConnectionStatusUpdated(cloudAgent: Actor, state: Components.Schemas.Connection.statePayload) async throws {
        let connectionId: String = cloudAgent.recall(key: "connectionId")
        try await Wait.until {
            let actualState = try await cloudAgent.using(OpenEnterpriseAPI.self).getConnection(connectionId).state
            return actualState == state
        }
    }
    
    static func offersACredential(cloudAgent: Actor) async throws {
        let connectionId: String = cloudAgent.recall(key: "connectionId")
        let credentialOfferRecord = try await cloudAgent.using(OpenEnterpriseAPI.self).offerCredential(connectionId)
        cloudAgent.remember(key: "recordId", value: credentialOfferRecord.recordId)
    }
    
    static func offersAnonymousCredential(cloudAgent: Actor) async throws {
        let connectionId: String = cloudAgent.recall(key: "connectionId")
        let credentialOfferRecord = try await cloudAgent.using(OpenEnterpriseAPI.self).offerAnonymousCredential(connectionId)
        cloudAgent.remember(key: "recordId", value: credentialOfferRecord.recordId)
    }
    
    static func asksForPresentProof(cloudAgent: Actor) async throws {
        let connectionId: String = cloudAgent.recall(key: "connectionId")
        let presentation = try await cloudAgent.using(OpenEnterpriseAPI.self).requestPresentProof(connectionId)
        cloudAgent.remember(key: "presentationId", value: presentation.presentationId)
    }
    
    static func verifyCredentialState(cloudAgent: Actor, recordId: String, state: Components.Schemas.IssueCredentialRecord.protocolStatePayload) async throws {
        try await Wait.until {
            let credentialRecord = try await cloudAgent.using(OpenEnterpriseAPI.self).getCredentialRecord(recordId)
            return credentialRecord.protocolState == state
        }
    }
    
    static func verifyPresentProof(cloudAgent: Actor, state: Components.Schemas.PresentationStatus.statusPayload) async throws {
        let presentationId: String = cloudAgent.recall(key: "presentationId")
        try await Wait.until {
            let presentationStatus = try await cloudAgent.using(OpenEnterpriseAPI.self).getPresentation(presentationId)
            return presentationStatus.status == state
        }
    }
}
