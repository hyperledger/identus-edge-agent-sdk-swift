//
//  ProofOfRequestTests.swift
//  
//
//  Created by io on 06/09/23.
//

import XCTest

final class ProofOfRequestFeature: Feature {
    override func featureTitle() -> String {
        "Provide proof of request"
    }
    
    override func featureDescription() -> String {
        "TThe Edge Agent should provide proof to Cloud Agent"
    }

    func testTest() async throws {
        try await Scenario("STUFFFFFFFFFF")
            .given("Cloud Agent is connected to Edge Agent")
            .when("Cloud Agent offers a credential")
            .then("Edge Agent should receive the credential")
            .when("Edge Agent accepts the credential")
            .when("Cloud Agent should see the credential was accepted")
            .then("Edge Agent wait to receive 1 issued credentials")
            .then("Edge Agent process 1 issued credentials")
            .run()
    }
}
