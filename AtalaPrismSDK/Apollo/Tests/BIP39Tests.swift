@testable import Apollo
import XCTest

final class BIP39Tests: XCTestCase {

    let mnemonics = ["blade", "multiply", "coil", "rare", "fox", "doll", "tongue", "please", "icon", "mind", "gesture", "moral", "old", "laugh", "symptom", "assume", "burden", "appear", "always", "oil", "ticket", "vault", "return", "height"]

    func testBip39SeedGeneration_WithoutPassword() throws {
        let seed = try CreateSeedOperation(words: mnemonics).compute()
        XCTAssertEqual(
            seed.value.base64UrlEncodedString(),
            "e8uNN7LRH5mEUcxa7FhxDAgWGLh8P94WEOD0jUdaJ2mSU1o02u-Lzao50elV32XvYT0ux9jWuBVECpFAz2ckKw"
        )
    }

    func testBip39SeedGeneration_WithPassword() throws {
        let seed = try CreateSeedOperation(words: mnemonics, passphrase: "test").compute()
        XCTAssertEqual(
            seed.value.base64UrlEncodedString(),
            "g-p5YM9M38keYsz760BqRQrEU-bhvU4Lc9ml0_IUowtaHH60XkkZKERjOiS_HugFSzGuU0cmCdziWEikGpiCDA"
        )
    }

}
