@testable import Apollo
import Core
import Domain
import XCTest

final class ECSigningTests: XCTestCase {
    func testSigning() throws {
        let privKey = PrivateKey(
            curve: .secp256k1(index: 0),
            value: Data(fromBase64URL: "xURclKhT6as1Tb9vg4AJRRLPAMWb9dYTTthDvXEKjMc")!
        )
        let testMessage = "test".data(using: .utf8)!

        let signing = try SignMessageOperation(
            privateKey: privKey,
            message: testMessage
        ).compute()

        XCTAssertEqual(
            signing.value.base64UrlEncodedString(),
            "MEUCIQDJroM8wtcJovEyZjl2unJpKZ_kbicRjPCJ2krzQzK31QIgcpe5CwIIXUrP63qOT-WzzmxVplHGhSO8R8h5-1ECKt4"
        )
    }
}
