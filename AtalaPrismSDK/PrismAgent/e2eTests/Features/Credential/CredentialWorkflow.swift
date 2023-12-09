import Foundation

class CredentialWorkflow {
    static func cloudAgentOffersACredential(cloudAgent: Actor) async throws {
        try await cloudAgent.using(OpenEnterpriseAPI.self).offerCredential()
    }
    
    static func edgeAgentShouldReceiveTheCredential(edgeAgent: Actor) async throws {
        print("receives")
    }
    
    static func edgeAgentAcceptsTheCredential(edgeAgent: Actor) async throws {
        print("accepts")
        
    }
    
    static func cloudAgentShouldSeeTheCredentialWasAccepted(cloudAgent: Actor) async throws {
        print("see was accepted")
        
    }
    
    static func edgeAgentWaitToReceiveIssuedCredentials(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        print("receive issued")
        
    }
    
    static func edgeAgentProcessIssuedCredentials(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        print("process")
    }
}
