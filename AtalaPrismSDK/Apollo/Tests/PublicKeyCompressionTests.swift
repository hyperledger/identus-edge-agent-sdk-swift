@testable import Apollo
import XCTest

final class PublicKeyCompressionTests: XCTestCase {

    func testCompressPublicKey() throws {
        let privateKey = LockPrivateKey(data: Data(fromBase64URL: "xURclKhT6as1Tb9vg4AJRRLPAMWb9dYTTthDvXEKjMc")!)

        let pubKey = privateKey.publicKey()
        print("Is key compressed: \(pubKey.isCompressed)")

        let compressedPubKey = pubKey.compressedPublicKey()
        print("Is key compressed: \(compressedPubKey.isCompressed)")

        let uncompressedPubKey = pubKey.uncompressedPublicKey()
        print("Is key compressed: \(uncompressedPubKey.isCompressed)")
    }
}
