
import Foundation

class CredentialSteps: Steps {
    @Step("buceta {actor} and {actor}")
    var buceta = { (cloudAgent: Actor, edgeAgent: Actor) in
        print(cloudAgent)
        print(edgeAgent)
        print(try cloudAgent.using(OpenEnterpriseAPI.self))
        print(try edgeAgent.using(Sdk.self))
    }
    
    @Step("{actor} offers a credential")
    var cloudAgentOffersACredential = { (cloudAgent: Actor) in
        try await CredentialWorkflow.cloudAgentOffersACredential(cloudAgent: cloudAgent)
    }
    
    @Step("{actor} should receive the credential")
    var edgeAgentShouldReceiveTheCredential = { (edgeAgent: Actor) in
        try await CredentialWorkflow.edgeAgentShouldReceiveTheCredential(edgeAgent: edgeAgent)
    }
    
    @Step("{actor} accepts the credential")
    var edgeAgentAcceptsTheCredential = { (edgeAgent: Actor) in
        try await CredentialWorkflow.edgeAgentAcceptsTheCredential(edgeAgent: edgeAgent)
    }
    
    @Step("{actor} should see the credential was accepted")
    var cloudAgentShouldSeeTheCredentialWasAccepted = { (cloudAgent: Actor) in
        try await CredentialWorkflow.cloudAgentShouldSeeTheCredentialWasAccepted(cloudAgent: cloudAgent)
    }
    
    @Step("{actor} wait to receive {int} issued credentials")
    var edgeAgentWaitToReceiveIssuedCredentials = { (edgeAgent: Actor, numberOfCredentials: Int) in
        try await CredentialWorkflow.edgeAgentWaitToReceiveIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: numberOfCredentials)
        
    }
    
    @Step("{actor} process {int} issued credentials")
    var edgeAgentProcessIssuedCredentials = { (edgeAgent: Actor, numberOfCredentials: Int) in
        try await CredentialWorkflow.edgeAgentProcessIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: numberOfCredentials)
    }
}
