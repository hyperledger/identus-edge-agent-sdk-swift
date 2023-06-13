@testable import Apollo
import Core
import Domain
import XCTest

final class ECVerification: XCTestCase {
    func testVerify() throws {
        let pubKey = Secp256k1PublicKey(
            lockedPublicKey: LockPublicKey(
                bytes: Data(fromBase64URL: "BD-l4lrQ6Go-oN5XtdpY6o5dyf2V2v5EbMAvRjVGJpE1gYVURJfxKMpNPnKlLr4MOLNVaYvBNOoy9L50E8jVx8Q")!
            ))

        let testMessage = "Test".data(using: .utf8)!
        let signature = Data(fromBase64URL: "MEUCIQCFeGlhJrH-9R70X4JzrurWs52SwuxCnJ8ky6riFwMOrwIgT7zlLo7URMHW5tiMgG73IOw2Dm3XyLl1iqW1-t5NFWQ")!

        XCTAssertTrue(try pubKey.verify(data: testMessage, signature: signature))
    }

}
