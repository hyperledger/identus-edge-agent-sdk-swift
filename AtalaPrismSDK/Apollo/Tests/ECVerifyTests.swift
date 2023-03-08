@testable import Apollo
import Core
import Domain
import XCTest

final class ECVerification: XCTestCase {

    func testVerify() throws {
        let pubKey = PublicKey(
            curve: KeyCurve.secp256k1().name,
            value: Data(fromBase64URL: "BHza5mV6_Iz6XdyMpxpjUMprZUCN_MpMuQCTFYpxSf8rW7N7DD04troywCgLkg0_ABP-IcxZcE1-qKjwCWYTVO8")!
        )
        let testMessage = "test".data(using: .utf8)!

        XCTAssertTrue(try VerifySignatureOperation(
            publicKey: pubKey,
            challenge: testMessage,
            signature: Signature(
                value: Data(
                    fromBase64URL: "MEUCIQDJroM8wtcJovEyZjl2unJpKZ_kbicRjPCJ2krzQzK31QIgcpe5CwIIXUrP63qOT-WzzmxVplHGhSO8R8h5-1ECKt4")!
            )
        ).compute())
    }

}
