import Domain
import Apollo
import Castor
import Builders
import CryptoKit
import Core
@testable import PrismAgent
import XCTest

final class CheckTests: XCTestCase {
//    func testCheck() throws {
//        let apollo = ApolloBuilder().build()
//        let castor = CastorBuilder(apollo: apollo).build()
//
//        let x255Key = apollo.createKeyPair(seed: Seed(value: Data()), curve: .x25519)
//        let ed255Key = apollo.createKeyPair(seed: Seed(value: Data()), curve: .ed25519)
//
//        let signer = try Curve25519.Signing.PrivateKey(rawRepresentation: ed255Key.privateKey.value)
//
//        let signature = try signer.signature(for: "Hello World".data(using: .utf8)!)
//
//        let did = try castor.createPeerDID(
//            keyAgreementKeyPair: x255Key,
//            authenticationKeyPair: ed255Key,
//            services: [])
//
//        print(did.string)
//        print(signature.base64UrlEncodedString())
//    }

    func testOOB() async throws {
        let oob = "https://mediator.rootsid.cloud?_oob=eyJ0eXBlIjoiaHR0cHM6Ly9kaWRjb21tLm9yZy9vdXQtb2YtYmFuZC8yLjAvaW52aXRhdGlvbiIsImlkIjoiNzk0Mjc4MzctY2MwNi00ODUzLWJiMzktNjg2ZWFjM2U2YjlhIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNtczU1NVloRnRobjFXVjhjaURCcFptODZoSzl0cDgzV29qSlVteFBHazFoWi5WejZNa21kQmpNeUI0VFM1VWJiUXc1NHN6bTh5dk1NZjFmdEdWMnNRVllBeGFlV2hFLlNleUpwWkNJNkltNWxkeTFwWkNJc0luUWlPaUprYlNJc0luTWlPaUpvZEhSd2N6b3ZMMjFsWkdsaGRHOXlMbkp2YjNSemFXUXVZMnh2ZFdRaUxDSmhJanBiSW1ScFpHTnZiVzB2ZGpJaVhYMCIsImJvZHkiOnsiZ29hbF9jb2RlIjoicmVxdWVzdC1tZWRpYXRlIiwiZ29hbCI6IlJlcXVlc3RNZWRpYXRlIiwibGFiZWwiOiJNZWRpYXRvciIsImFjY2VwdCI6WyJkaWRjb21tL3YyIl19fQ"
        let agent = PrismAgent(mediatorDID: DID(method: "peer", methodId: "123"))

        let parsed = try await agent.parseInvitation(str: oob)
        print(parsed)
    }
}
