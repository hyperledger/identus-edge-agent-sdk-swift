import Domain
import Apollo
import Castor
import Builders
import CryptoKit
import Core
@testable import PrismAgent
import XCTest

final class CheckTests: XCTestCase {
    func testCheck() throws {
        let apollo = ApolloBuilder().build()
        let castor = CastorBuilder(apollo: apollo).build()

        let x255Key = apollo.createKeyPair(seed: Seed(value: Data()), curve: .x25519)
        let ed255Key = apollo.createKeyPair(seed: Seed(value: Data()), curve: .ed25519)

        let signer = try Curve25519.Signing.PrivateKey(rawRepresentation: ed255Key.privateKey.value)

        let signature = try signer.signature(for: "Hello World".data(using: .utf8)!)

        let did = try castor.createPeerDID(
            keyAgreementKeyPair: x255Key,
            authenticationKeyPair: ed255Key,
            services: [])

        print(did.string)
        print(signature.base64UrlEncodedString())
    }
}
