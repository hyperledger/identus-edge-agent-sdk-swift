@testable import Apollo
import Core
import Domain
import XCTest

final class ECSigningTests: XCTestCase {
    func testSigning() throws {
        let privKey = Secp256k1PrivateKey(
            lockedPrivateKey: .init(
                data: Data(fromBase64URL: "N_JFgvYaReyRXwassz5FHg33A4I6dczzdXrjdHGksmg")!
            ),
            derivationPath: .init(index: 0)
        )
        let testMessage = "Test".data(using: .utf8)!

        let signing = try privKey.sign(data: testMessage)

        XCTAssertEqual(
            signing.raw.base64UrlEncodedString(),
            "MEUCIQCFeGlhJrH-9R70X4JzrurWs52SwuxCnJ8ky6riFwMOrwIgT7zlLo7URMHW5tiMgG73IOw2Dm3XyLl1iqW1-t5NFWQ"
        )
    }
}
