import AnoncredsSwift
@testable import Pollux
import XCTest

final class AnoncredsTests: XCTestCase {
    let issuer = MockIssuer()
    var linkSecret: LinkSecret!

    override func setUp() async throws {
        linkSecret = try LinkSecret.newFromValue(valueString: "28380340054639370074509985417762391330214600660319893567746760706478614060614")
    }

    func testCreateMessageRequest() async throws {
        let offer = try issuer.createOfferMessage()
        let linkSecretValue = try linkSecret.getValue()
        let credDef = issuer.credDef
        let defDownloader = MockDownloader(returnData: try credDef.getJson().data(using: .utf8)!)

        // No error means it passed
        _ = try await PolluxImpl().processCredentialRequest(
            offerMessage: offer,
            options: [
                .linkSecret(id: "test", secret: linkSecretValue),
                .credentialDefinitionDownloader(downloader: defDownloader),
                .subjectDID(.init(method: "test", methodId: "adasdadde"))
            ]
        )
    }

    func testParseIssueCredential() async throws {
        let offer = try issuer.createOffer()
        let linkSecretValue = try linkSecret.getValue()

        let credDef = issuer.credDef
        let defDownloader = MockDownloader(returnData: try credDef.getJson().data(using: .utf8)!)
        let prover = try MockProver(linkSecret: linkSecret, credDef: credDef)
        let request = try prover.createRequest(offer: offer)
        let issuedMessage = try issuer.issueCredential(offer: offer, request: request.0)
        let credential = try await PolluxImpl().parseCredential(
            issuedCredential: issuedMessage,
            options: [
                .linkSecret(id: "test", secret: linkSecretValue),
                .credentialDefinitionDownloader(downloader: defDownloader),
            ]
        )

        XCTAssertEqual(credential.claims.first?.key, "test")
        XCTAssertEqual(credential.claims.first?.getValueAsString(), "test")
    }
}
