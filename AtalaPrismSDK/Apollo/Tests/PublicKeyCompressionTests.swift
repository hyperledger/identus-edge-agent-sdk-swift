@testable import Apollo
import XCTest

final class PublicKeyCompressionTests: XCTestCase {

    func testCompressPublicKey() throws {
        let privateKey = LockPrivateKey(data: Data(fromBase64URL: "xURclKhT6as1Tb9vg4AJRRLPAMWb9dYTTthDvXEKjMc")!)

        let pubKey = privateKey.publicKey()
        XCTAssertFalse(pubKey.isCompressed)

        let compressedPubKey = pubKey.compressedPublicKey()
        XCTAssertTrue(compressedPubKey.isCompressed)

        let uncompressedPubKey = pubKey.uncompressedPublicKey()
        XCTAssertFalse(uncompressedPubKey.isCompressed)
    }
}
