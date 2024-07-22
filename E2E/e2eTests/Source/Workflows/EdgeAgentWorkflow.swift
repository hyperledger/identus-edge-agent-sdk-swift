import Foundation
import Domain
import EdgeAgent
import XCTest
import PeerDID
import Combine
import SwiftHamcrest

class EdgeAgentWorkflow {
    static func connectsThroughTheInvite(edgeAgent: Actor) async throws {
        let invitation: String = try edgeAgent.recall(key: "invitation")
        let url = URL(string: invitation)!
        
        let oob = try edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "parses an OOB invitation"
        ).sdk.parseOOBInvitation(url: url)
        
        try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "accepts an invitation"
        ).sdk.acceptDIDCommInvitation(invitation: oob)
    }
    
    static func waitToReceiveCredentialsOffer(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        try await edgeAgent.waitUsingAbility(
            ability: UseWalletSdk.self,
            action: "credential offer count to be \(numberOfCredentials)"
        ) { ability in
            return ability.credentialOfferStack.count == numberOfCredentials
        }
    }
    
    static func hasIssuedCredentials(edgeAgent: Actor, numberOfCredentialsIssued: Int, cloudAgent: Actor) async throws {
        for _ in 0..<numberOfCredentialsIssued {
            try await CloudAgentWorkflow.offersACredential(cloudAgent: cloudAgent)
            try await EdgeAgentWorkflow.waitToReceiveCredentialsOffer(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.acceptsTheCredentialOffer(edgeAgent: edgeAgent)
            let recordId: String = try cloudAgent.recall(key: "recordId")
            try await CloudAgentWorkflow.verifyCredentialState(cloudAgent: cloudAgent, recordId: recordId, expectedState: .CredentialSent)
            try await EdgeAgentWorkflow.waitToReceiveIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.processIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: 1)
        }
    }
    
    static func hasIssuedAnonymousCredentials(edgeAgent: Actor, numberOfCredentialsIssued: Int, cloudAgent: Actor) async throws {
        for _ in 0..<numberOfCredentialsIssued {
            try await CloudAgentWorkflow.offersAnonymousCredential(cloudAgent: cloudAgent)
            try await EdgeAgentWorkflow.waitToReceiveCredentialsOffer(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.acceptsTheCredentialOffer(edgeAgent: edgeAgent)
            let recordId: String = try cloudAgent.recall(key: "recordId")
            try await CloudAgentWorkflow.verifyCredentialState(cloudAgent: cloudAgent, recordId: recordId, expectedState: .CredentialSent)
            try await EdgeAgentWorkflow.waitToReceiveIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.processIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: 1)
        }
    }
    
    static func acceptsTheCredentialOffer(edgeAgent: Actor) async throws {
        let message: Message = try edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "gets the first credential offer"
        ).credentialOfferStack.first!
        
        try edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "removes it from list"
        ).credentialOfferStack.removeFirst()
        
        let acceptOfferMessage = try OfferCredential3_0.init(fromMessage: message)
        let did = try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "create a new prism DID"
        ).sdk.createNewPrismDID()
        
        let requestCredential = try await edgeAgent
            .using(
                ability: UseWalletSdk.self,
                action: "request a credential"
            )
            .sdk
            .prepareRequestCredentialWithIssuer(
                did: did,
                offer: acceptOfferMessage
            )!.makeMessage()
        
        _ = try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "send a message"
        ).sdk.sendMessage(message: requestCredential)
    }
    
    static func waitToReceiveIssuedCredentials(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        try await edgeAgent.waitUsingAbility(
            ability: UseWalletSdk.self,
            action: "wait for issued credentials to be \(numberOfCredentials)"
        ) { ability in
            return ability.issueCredentialStack.count == numberOfCredentials
        }
    }
    
    static func processIssuedCredentials(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        for _ in 0..<numberOfCredentials {
            let message = try edgeAgent.using(
                ability: UseWalletSdk.self,
                action: "get an issued credential"
            ).issueCredentialStack.first!
            try edgeAgent.using(
                ability: UseWalletSdk.self,
                action: "remove it from list"
            ).issueCredentialStack.removeFirst()
            let issuedCredential = try IssueCredential3_0(fromMessage: message)
            _ = try await edgeAgent.using(
                ability: UseWalletSdk.self,
                action: "process the credential"
            ).sdk.processIssuedCredentialMessage(message: issuedCredential)
        }
    }
    
    static func waitForProofRequest(edgeAgent: Actor) async throws {
        try await edgeAgent.waitUsingAbility(
            ability: UseWalletSdk.self,
            action: "wait for present proof request"
        ) { ability in
            return ability.proofOfRequestStack.count == 1
        }
    }
    
    static func presentProof(edgeAgent: Actor) async throws {
        let credential = try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "get a verifiable credential"
        ).sdk.verifiableCredentials().map { $0.first }.first().await()
        
        let message = try edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "get proof request"
        ).proofOfRequestStack.first!
        try edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "remove it from list"
        ).proofOfRequestStack.removeFirst()
        let requestPresentationMessage = try RequestPresentation(fromMessage: message)
        let sendProofMessage = try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "make message"
        ).sdk.createPresentationForRequestProof(request: requestPresentationMessage, credential: credential!).makeMessage()
        do {
            _ = try await edgeAgent.using(
                ability: UseWalletSdk.self,
                action: "send message"
            ).sdk.sendMessage(message: sendProofMessage)
        } catch {
            print("error", error)
        }
    }
    
    static func createBackup(edgeAgent: Actor) async throws {
        let backup = try await edgeAgent.using(ability: UseWalletSdk.self, action: "creates a backup").sdk.backupWallet()
        let seed = try edgeAgent.using(ability: UseWalletSdk.self, action: "gets seed phrase").sdk.seed
        try edgeAgent.remember(key: "backup", value: backup)
        try edgeAgent.remember(key: "seed", value: seed)
    }
    
    static func createNewWalletFromBackup(edgeAgent: Actor) async throws {
        let backup: String = try edgeAgent.recall(key: "backup")
        let seed: Seed = try edgeAgent.recall(key: "seed")
        let walletSdk = UseWalletSdk()
        try await walletSdk.createSdk(seed: seed)
        try await walletSdk.sdk.recoverWallet(encrypted: backup)
        try await walletSdk.sdk.start()
        try await walletSdk.sdk.stop()
    }
    
    static func createNewWalletFromBackupWithWrongSeed(edgeAgent: Actor) async throws {
        let backup: String = try edgeAgent.recall(key: "backup")
        let seed = UseWalletSdk.wrongSeed
        
        do {
            let walletSdk = UseWalletSdk()
            try await walletSdk.createSdk(seed: seed)
            try await walletSdk.sdk.recoverWallet(encrypted: backup)
            XCTFail("SDK should not be able to restore with wrong seed phrase.")
        } catch {
        }
    }
    
    static func createPeerDids(edgeAgent: Actor, numberOfDids: Int) async throws {
        for _ in 0..<numberOfDids {
            _ = try await edgeAgent.using(ability: UseWalletSdk.self, action: "creates peer did").sdk.createNewPeerDID(updateMediator: true)
        }
        
    }
    
    static func createPrismDids(edgeAgent: Actor, numberOfDids: Int) async throws {
        for _ in 0..<numberOfDids {
            _ = try await edgeAgent.using(ability: UseWalletSdk.self, action: "creates peer did").sdk.createNewPrismDID()
        }
    }
    
    static func backupAndRestoreToNewAgent(newAgent: Actor, oldAgent: Actor) async throws {
        let backup: String = try oldAgent.recall(key: "backup")
        let seed: Seed = try oldAgent.recall(key: "seed")
        let walletSdk = UseWalletSdk()
        try await walletSdk.createSdk(seed: seed)
        try await walletSdk.sdk.recoverWallet(encrypted: backup)
        try await walletSdk.startSdk()
        _ = newAgent.whoCanUse(walletSdk)
    }
    
    static func newAgentShouldMatchOldAgent(newAgent: Actor, oldAgent: Actor) async throws {
        let expectedCredentials: [Credential] = try await oldAgent.using(
            ability: UseWalletSdk.self,
            action: "gets credentials"
        ).sdk.verifiableCredentials().first().await()
        let expectedPeerDids: [PeerDID] = try await oldAgent.using(
            ability: UseWalletSdk.self,
            action: "gets peer dids"
        ).sdk.pluto.getAllPeerDIDs().first().await().map { try PeerDID(didString: $0.did.string) }
        let expectedPrismDids: [DID] = try await oldAgent.using(
            ability: UseWalletSdk.self,
            action: "gets prism dids"
        ).sdk.pluto.getAllPrismDIDs().first().await().map { try DID(string: $0.did.string) }
        let expectedDidPairs: [DIDPair] = try await oldAgent.using(
            ability: UseWalletSdk.self,
            action: "gets did pairs"
        ).sdk.pluto.getAllDidPairs().first().await()
        
        let actualCredentials: [Credential] = try await newAgent.using(
            ability: UseWalletSdk.self,
            action: "gets credentials"
        ).sdk.verifiableCredentials().first().await()
        let actualPeerDids: [PeerDID] = try await newAgent.using(
            ability: UseWalletSdk.self,
            action: "gets peer dids"
        ).sdk.pluto.getAllPeerDIDs().first().await().map { try PeerDID(didString: $0.did.string) }
        let actualPrismDids: [DID] = try await newAgent.using(
            ability: UseWalletSdk.self,
            action: "gets prism dids"
        ).sdk.pluto.getAllPrismDIDs().first().await().map { try DID(string: $0.did.string) }
        let actualDidPairs: [DIDPair] = try await newAgent.using(
            ability: UseWalletSdk.self,
            action: "gets did pairs"
        ).sdk.pluto.getAllDidPairs().first().await()
        
        assertThat(expectedCredentials.count == actualCredentials.count)
        assertThat(expectedPeerDids.count == actualPeerDids.count)
        assertThat(expectedPrismDids.count == actualPrismDids.count)
        assertThat(expectedDidPairs.count == actualDidPairs.count)
        
        expectedCredentials.forEach { expectedCredential in
            assertThat(actualCredentials.contains(where: { $0.id == expectedCredential.id }), equalTo(true))
        }
        expectedPeerDids.forEach { expectedPeerDid in
            assertThat(actualPeerDids.contains(where: { $0.string == expectedPeerDid.string }), equalTo(true))
        }
        expectedPrismDids.forEach { expectedPrismDid in
            assertThat(actualPrismDids.contains(where: { $0.string == expectedPrismDid.string }), equalTo(true))
        }
        expectedDidPairs.forEach { expectedDidPair in
            assertThat(actualDidPairs.contains(where: { $0.name == expectedDidPair.name }), equalTo(true))
        }
    }
}
