@testable import Apollo
import Core
import Domain
import XCTest

final class BIP32Tests: XCTestCase {

    let mnemonics = ["blade", "multiply", "coil", "rare", "fox", "doll", "tongue", "please", "icon", "mind", "gesture", "moral", "old", "laugh", "symptom", "assume", "burden", "appear", "always", "oil", "ticket", "vault", "return", "height"]

    func testBip32RootKeyGeneration() throws {
        let seed = try CreateSeedOperation(words: mnemonics).compute()
        let operation = CreateSec256k1KeyPairOperation(seed: seed, keyPath: .init(index: 0))
        let privateKey = try operation.compute()
        XCTAssertEqual(
            privateKey.privateKey.value.base64UrlEncodedString(),
            "xURclKhT6as1Tb9vg4AJRRLPAMWb9dYTTthDvXEKjMc"
        )
    }

    func testBip32KeyPathGeneration() throws {
        let seed = try CreateSeedOperation(words: mnemonics).compute()
        let operation = CreateSec256k1KeyPairOperation(seed: seed, keyPath: .init(index: 3))
        let privateKey = try operation.compute()
        XCTAssertEqual(
            privateKey.privateKey.value.base64UrlEncodedString(),
            "N_JFgvYaReyRXwassz5FHg33A4I6dczzdXrjdHGksmg"
        )
    }
}
