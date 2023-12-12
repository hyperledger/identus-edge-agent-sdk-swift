import Foundation
import Domain
import PrismAgent

class EdgeAgentWorkflow {
    static func connectsThroughTheInvite(edgeAgent: Actor) async throws {
        let invitation: String = edgeAgent.recall(key: "invitation")
        let url = URL(string: invitation)!
        
        let oob = try edgeAgent.using(Sdk.self).prismAgent.parseOOBInvitation(url: url)
        try await edgeAgent.using(Sdk.self).prismAgent.acceptDIDCommInvitation(invitation: oob)
    }
    
    static func waitToReceiveCredentialsOffer(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        try await Wait.until {
            return try edgeAgent.using(Sdk.self).credentialOfferStack.count == numberOfCredentials
        }
    }
    
    static func hasIssuedCredentials(edgeAgent: Actor, numberOfCredentialsIssued: Int, cloudAgent: Actor) async throws {
        for _ in 0..<numberOfCredentialsIssued {
            try await CloudAgentWorkflow.offersACredential(cloudAgent: cloudAgent)
            try await EdgeAgentWorkflow.waitToReceiveCredentialsOffer(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.acceptsTheCredentialOffer(edgeAgent: edgeAgent)
            let recordId: String = cloudAgent.recall(key: "recordId")
            try await CloudAgentWorkflow.verifyCredentialState(cloudAgent: cloudAgent, recordId: recordId, state: .CredentialSent)
            try await EdgeAgentWorkflow.waitToReceiveIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.processIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: 1)
        }
    }
    
    static func acceptsTheCredentialOffer(edgeAgent: Actor) async throws {
        let message: Message = try edgeAgent.using(Sdk.self).credentialOfferStack.first!
        try edgeAgent.using(Sdk.self).credentialOfferStack.removeFirst()
        
        let acceptOfferMessage = try OfferCredential3_0.init(fromMessage: message)
        let did = try await edgeAgent.using(Sdk.self).prismAgent.createNewPrismDID()
        
        let requestCredential = try await edgeAgent
            .using(Sdk.self)
            .prismAgent
            .prepareRequestCredentialWithIssuer(
                did: did,
                offer: acceptOfferMessage
            )!.makeMessage()
        
        _ = try await edgeAgent.using(Sdk.self).prismAgent.sendMessage(message: requestCredential)
        
    }
    
    static func waitToReceiveIssuedCredentials(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        try await Wait.until {
            return try edgeAgent.using(Sdk.self).issueCredentialStack.count == numberOfCredentials
        }
    }
    
    static func processIssuedCredentials(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        for _ in 0..<numberOfCredentials {
            let message = try edgeAgent.using(Sdk.self).issueCredentialStack.first!
            try edgeAgent.using(Sdk.self).issueCredentialStack.removeFirst()
            let issuedCredential = try IssueCredential3_0(fromMessage: message)
            _ = try await edgeAgent.using(Sdk.self).prismAgent.processIssuedCredentialMessage(message: issuedCredential)
        }
    }
    
    static func waitForProofRequest(edgeAgent: Actor) async throws {
        try await Wait.until {
            return try edgeAgent.using(Sdk.self).proofOfRequestStack.count == 1
        }
    }
    
    static func presentProof(edgeAgent: Actor) async throws {
        let credential = try await edgeAgent.using(Sdk.self).prismAgent.verifiableCredentials().map { $0.first }.first().await()
        let message = try edgeAgent.using(Sdk.self).proofOfRequestStack.first!
        try edgeAgent.using(Sdk.self).proofOfRequestStack.removeFirst()
        let requestPresentationMessage = try RequestPresentation(fromMessage: message)
        let sendProofMessage = try await edgeAgent.using(Sdk.self).prismAgent.createPresentationForRequestProof(request: requestPresentationMessage, credential: credential!).makeMessage()
        _ = try await edgeAgent.using(Sdk.self).prismAgent.sendMessage(message: sendProofMessage)
    }
}
