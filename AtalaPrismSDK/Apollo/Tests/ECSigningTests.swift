@testable import Apollo
import Core
import Domain
import XCTest

final class ECSigningTests: XCTestCase {
    func testSigning() throws {
        let privKey = PrivateKey(
            curve: .secp256k1(index: 3),
            value: Data(fromBase64URL: "N_JFgvYaReyRXwassz5FHg33A4I6dczzdXrjdHGksmg")!
        )
        let testMessage = "Test".data(using: .utf8)!

        let signing = try SignMessageOperation(
            privateKey: privKey,
            message: testMessage
        ).compute()

        XCTAssertEqual(
            signing.value.base64UrlEncodedString(),
            "MEUCIQCFeGlhJrH-9R70X4JzrurWs52SwuxCnJ8ky6riFwMOrwIgT7zlLo7URMHW5tiMgG73IOw2Dm3XyLl1iqW1-t5NFWQ"
        )
    }
}
