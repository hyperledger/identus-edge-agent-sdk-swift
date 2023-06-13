import Apollo
import Domain
@testable import Castor
import XCTest

final class PeerDIDCreationTests: XCTestCase {
    func testPeerDIDCreation() throws {
        let validPeerDID = "did:peer:2.Ez6LSoHkfN1Y4nK9RCjx7vopWsLrMGNFNgTNZgoCNQrTzmb1n.Vz6MknRZmapV7uYZQuZez9n9N3tQotjRN18UGS68Vcfo6gR4h.SeyJyIjpbImRpZDpleGFtcGxlOnNvbWVtZWRpYXRvciNzb21la2V5Il0sInMiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50IiwiYSI6W10sInQiOiJkbSJ9"
        let apollo = ApolloImpl()
        let castor = CastorImpl(apollo: apollo)
        let keyAgreementPrivateKey = try apollo.createPrivateKey(parameters: [
            KeyProperties.type.rawValue: "EC",
            KeyProperties.curve.rawValue: KnownKeyCurves.x25519.rawValue,
            KeyProperties.rawKey.rawValue: Data(base64URLEncoded: "COd9Xhr-amD7fuswWId2706JBUY_tmjp9eiNEieJeEE")!.base64Encoded()
        ])


        let authenticationPrivateKey = try apollo.createPrivateKey(parameters: [
            KeyProperties.type.rawValue: "EC",
            KeyProperties.curve.rawValue: KnownKeyCurves.ed25519.rawValue,
            KeyProperties.rawKey.rawValue: Data(base64URLEncoded: "JLIJQ5jlkyqtGmtOth6yggJLLC0zuRhUPiBhd1-rGPs")!.base64Encoded()
        ])

        let service = DIDDocument.Service(
            id: "didcomm",
            type: ["DIDCommMessaging"],
            serviceEndpoint: [.init(
                uri: "https://example.com/endpoint",
                routingKeys: ["did:example:somemediator#somekey"]
            )]
        )
        let did = try castor.createPeerDID(
            keyAgreementPublicKey: keyAgreementPrivateKey.publicKey(),
            authenticationPublicKey: authenticationPrivateKey.publicKey(),
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

        let mypeerDIDString = "did:peer:2.Ez6LSmx3k5X9xMos7VXdMDJx1CGNTd2tWfLTVyMtu3toJWqPo.Vz6Mkvcu3GqbvM3vr5W1sDVe41wmLeUL6a7b4wEcrGw6ULATR.SeyJ0IjoiZG0iLCJzIjoiazhzLWRldi5hdGFsYXByaXNtLmlvL3ByaXNtLWFnZW50L2RpZGNvbW0iLCJyIjpbXSwiYSI6WyJkaWRjb21tL3YyIl19"

        let mypeerDID = DID(
            schema: "did",
            method: "peer",
            methodId: "2.Ez6LSms555YhFthn1WV8ciDBpZm86hK9tp83WojJUmxPGk1hZ.Vz6MkmdBjMyB4TS5UbbQw54szm8yvMMf1ftGV2sQVYAxaeWhE.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwczovL21lZGlhdG9yLnJvb3RzaWQuY2xvdWQiLCJhIjpbImRpZGNvbW0vdjIiXX0"
        )

        let apollo = ApolloImpl()
        let castor = CastorImpl(apollo: apollo)
        let document = try await castor.resolveDID(did: mypeerDID)
        print(document)
    }
}
