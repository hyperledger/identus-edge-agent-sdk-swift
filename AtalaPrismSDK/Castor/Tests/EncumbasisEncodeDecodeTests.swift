import Core
import Domain
@testable import Castor
import XCTest

final class EncumbasisEncodeDecodeTests: XCTestCase {
    func testDecodeEcnumbasis() throws {
        let valueDic = [
            "crv" : "Ed25519",
            "kty" : "OKP",
            "x" : "owBhCbktDjkfS6PdQddT0D3yjSitaSysP3YimJ_YgmA"
        ]
        let valueJson = try convertToJsonString(dic: valueDic)!
        let ecnumBasis = "z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V"
        let result = VerificationMaterialAuthentication(
            format: .jwk,
            value: valueJson,
            type: .jsonWebKey2020
        )

        let ecnumbasisResult = try PeerDIDResolver().decodeMultibaseEncnumbasisAuth(
            did: DID(method: "test", methodId: "test1"),
            multibase: ecnumBasis,
            format: .jwk
        )

        XCTAssertEqual(result.type, ecnumbasisResult.1.type)
        XCTAssertEqual(result.value, ecnumbasisResult.1.value)
        XCTAssertEqual(result.format, ecnumbasisResult.1.format)
    }
}
