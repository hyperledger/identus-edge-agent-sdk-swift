import AnoncredsSwift
import Builders
import Core
import Domain
@testable import EdgeAgent
@testable import Pollux
import XCTest

final class AnoncredsPresentationFlowTest: XCTestCase {
    let issuer = MockIssuer()
    var apollo: Apollo & KeyRestoration = ApolloBuilder().build()
    var pluto = MockPluto()
    var castor: Castor!
    var pollux: (Pollux & CredentialImporter)!
    var mercury = MercuryStub()
    var edgeAgent: DIDCommAgent!
    var linkSecret: Key!

    override func setUp() async throws {
        castor = CastorBuilder(apollo: apollo).build()
        pollux = PolluxBuilder(pluto: pluto, castor: castor).build()
        let edgeAgent = EdgeAgent(
            apollo: apollo,
            castor: castor,
            pluto: pluto,
            pollux: pollux
        )
        self.edgeAgent = DIDCommAgent(edgeAgent: edgeAgent, mercury: mercury)
        linkSecret = try apollo.createNewLinkSecret()
    }

    func testAnoncredsFlow() async throws {
        let credDef = issuer.credDef
        let credential = try await credentialIssuance()
        
        try await edgeAgent.pluto.storeCredential(credential: credential.storable!).first().await()

        let presentationRequest = try await edgeAgent.initiatePresentationRequest(
            type: .anoncred,
            fromDID: DID(method: "test", methodId: "alice"),
            toDID: DID(method: "test", methodId: "bob"),
            claimFilters: [
                .init(paths: [], type: "sex"),
                .init(paths: [], type: "age", const: "20", pattern: ">=")
            ]
        )

        try await edgeAgent.pluto.storeMessage(message: presentationRequest.makeMessage(), direction: .sent)
            .first()
            .await()

        let presentation = try await edgeAgent.createPresentationForRequestProof(
            request: presentationRequest,
            credential: credential,
            options: [.disclosingClaims(claims: ["test"])]
        )

        let verification = try await edgeAgent.pollux.verifyPresentation(
            message: presentation.makeMessage(),
            options: [
                .schema(id: "mock:uri2", json: issuer.getSchemaJson()),
                .credentialDefinition(id: "mock:uri3", json: try credDef.getJson())
            ]
        )

        XCTAssert(verification)
    }

    private func credentialIssuance() async throws -> Domain.Credential {
        let offer = try issuer.createOffer()
        let linkSecretValue = try linkSecret.raw.tryToString()

        try await edgeAgent.pluto.storeLinkSecret(secret: linkSecret.storable!).first().await()

        let credDef = issuer.credDef
        let defDownloader = MockDownloader(returnData: try credDef.getJson().data(using: .utf8)!)
        let schemaDownloader = MockDownloader(returnData: issuer.getSchemaJson().data(using: .utf8)!)
        let prover = MockProver(linkSecret: linkSecret, credDef: credDef)
        let request = try prover.createRequest(offer: offer)
        let credentialMetadata = try StorableCredentialRequestMetadata(
            metadataJson: request.1.getJson().tryData(using: .utf8),
            storingId: "1"
        )
        try await edgeAgent.pluto.storeCredential(credential: credentialMetadata).first().await()
        let issuedMessage = try issuer.issueCredential(offer: offer, request: request.0)
        return try await PolluxImpl(castor: castor, pluto: pluto).parseCredential(
            issuedCredential: issuedMessage,
            options: [
                .linkSecret(id: "test", secret: linkSecretValue),
                .credentialDefinitionDownloader(downloader: defDownloader),
                .schemaDownloader(downloader: schemaDownloader)
            ]
        )
    }
}
