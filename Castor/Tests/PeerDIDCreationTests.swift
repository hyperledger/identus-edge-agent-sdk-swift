import Apollo
import Domain
@testable import Castor
import XCTest

final class PeerDIDCreationTests: XCTestCase {
    func testPeerDIDCreation() throws {
        let validPeerDID = "did:peer:2.Ez6LSoHkfN1Y4nK9RCjx7vopWsLrMGNFNgTNZgoCNQrTzmb1n.Vz6MknRZmapV7uYZQuZez9n9N3tQotjRN18UGS68Vcfo6gR4h.SeyJyIjpbImRpZDpleGFtcGxlOnNvbWVtZWRpYXRvciNzb21la2V5Il0sInMiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50IiwiYSI6W10sInQiOiJkbSJ9"
        let apollo = ApolloImpl()
        let castor = CastorImpl(apollo: apollo)
        let keyAgreementKeyPair = KeyPair(
            curve: .x25519,
            privateKey: .init(
                curve: "X25519",
                value: Data(base64URLEncoded: "COd9Xhr-amD7fuswWId2706JBUY_tmjp9eiNEieJeEE")!
            ),
            publicKey: .init(
                curve: "X25519",
                value: Data(base64URLEncoded: "rI3CjEk-yaFi5bQTavOmV25EJHQnDQJeIi4OV6p_f2U")!
        ))

        let authenticationKeyPair = KeyPair(
            curve: .ed25519,
            privateKey: .init(
                curve: "Ed25519",
                value: Data(base64URLEncoded: "JLIJQ5jlkyqtGmtOth6yggJLLC0zuRhUPiBhd1-rGPs")!
            ),
            publicKey: .init(
                curve: "Ed25519",
                value: Data(base64URLEncoded: "dm5f2GdR5BaHpRxB8bTElvE_0gIC2p404Msx9swJ914")!
        ))

        let service = DIDDocument.Service(
            id: "didcomm",
            type: ["DIDCommMessaging"],
            serviceEndpoint: .init(
                uri: "https://example.com/endpoint",
                routingKeys: ["did:example:somemediator#somekey"]
            )
        )
        let did = try castor.createPeerDID(
            keyAgreementKeyPair: keyAgreementKeyPair,
            authenticationKeyPair: authenticationKeyPair,
            services: [service]
        )

        print(did.string)
        XCTAssertEqual(did.string, validPeerDID)
    }

    func testResolvePeerDID() async throws {
        let peerDIDString = "did:peer:2.Ez6LSci5EK4Ezue5QA72ZX71QUbXY2xr5ygRw7wM1WJigTNnd.Vz6MkqgCXHEGr2wJZANPZGC8WFmeVuS3abAD9uvh7mTXygCFv.SeyJ0IjoiZG0iLCJzIjoibG9jYWxob3N0OjgwODIiLCJyIjpbXSwiYSI6WyJkaWRjb21tL3YyIl19"

        let peerDID = DID(
            schema: "did",
            method: "peer",
            methodId: "2.Ez6LSci5EK4Ezue5QA72ZX71QUbXY2xr5ygRw7wM1WJigTNnd.Vz6MkqgCXHEGr2wJZANPZGC8WFmeVuS3abAD9uvh7mTXygCFv.SeyJ0IjoiZG0iLCJzIjoibG9jYWxob3N0OjgwODIiLCJyIjpbXSwiYSI6WyJkaWRjb21tL3YyIl19"
        )

        let mypeerDIDString = "did:peer:2.Ez6LSoHkfN1Y4nK9RCjx7vopWsLrMGNFNgTNZgoCNQrTzmb1n.Vz6MknRZmapV7uYZQuZez9n9N3tQotjRN18UGS68Vcfo6gR4h.SeyJyIjpbImRpZDpleGFtcGxlOnNvbWVtZWRpYXRvciNzb21la2V5Il0sInMiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50IiwiYSI6W10sInQiOiJkbSJ9"

        let mypeerDID = DID(
            schema: "did",
            method: "peer",
            methodId: "2.Ez6LSoHkfN1Y4nK9RCjx7vopWsLrMGNFNgTNZgoCNQrTzmb1n.Vz6MknRZmapV7uYZQuZez9n9N3tQotjRN18UGS68Vcfo6gR4h.SeyJyIjpbImRpZDpleGFtcGxlOnNvbWVtZWRpYXRvciNzb21la2V5Il0sInMiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50IiwiYSI6W10sInQiOiJkbSJ9"
        )

        let apollo = ApolloImpl()
        let castor = CastorImpl(apollo: apollo)
        let document = try await castor.resolveDID(did: mypeerDID)
    }
}
