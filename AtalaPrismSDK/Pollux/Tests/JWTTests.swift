import Apollo
import Castor
import Domain
import CryptoKit
@testable import Pollux
import XCTest
import secp256k1

final class JWTTests: XCTestCase {

    lazy var apollo = ApolloImpl()
    lazy var castor = CastorImpl(apollo: apollo)

    func testJWTPresentationSignature() throws {
        let privKey = PrivateKey(
            curve: .secp256k1(index: 3),
            value: Data(fromBase64URL: "N_JFgvYaReyRXwassz5FHg33A4I6dczzdXrjdHGksmg")!
        )
        let pubKey = PublicKey(
            curve: KeyCurve.secp256k1().name,
            value: Data(fromBase64URL: "BD-l4lrQ6Go-oN5XtdpY6o5dyf2V2v5EbMAvRjVGJpE1gYVURJfxKMpNPnKlLr4MOLNVaYvBNOoy9L50E8jVx8Q")!
        )
        let issuerPrismDID = try castor.createPrismDID(masterPublicKey: pubKey, services: [])
        let jwtCredential = JWTCredentialPayload(
            iss: issuerPrismDID,
            sub: nil,
            verifiableCredential: .init(credentialSubject: ["test":"test"]),
            nbf: Date(),
            exp: nil,
            jti: "",
            aud: Set([""]),
            originalJWTString: "Test.JWT.String"
        )
        let ownerPrismDID = try castor.createPrismDID(masterPublicKey: pubKey, services: [])
        let apollo = ApolloImpl()
        let castor = CastorImpl(apollo: apollo)
        let pollux = PolluxImpl(apollo: apollo, castor: castor)


        let jwt = try pollux.createVerifiablePresentationJWT(
            did: ownerPrismDID,
            privateKey: privKey,
            credential: jwtCredential,
            challenge: "testChallenge",
            domain: "testDomain"
        )

        let components = jwt.components(separatedBy: ".")
        XCTAssertEqual(components.count, 3)
        let claims = String(data: Data(fromBase64URL: components[1])!, encoding: .utf8)!
        XCTAssertTrue(claims.contains("\"nonce\":\"testChallenge\""))
        XCTAssertTrue(claims.contains("\"Test.JWT.String\""))
        XCTAssertTrue(claims.contains("\"aud\":\"testDomain\""))
    }
}
