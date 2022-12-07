@testable import Castor
import XCTest

final class MultiCodecTests: XCTestCase {
    func testMulticodecCoding() throws {
        let testData = "test1".data(using: .utf8)!
        let multiCodec = Multicodec(value: testData, keyType: .agreement)
        XCTAssertEqual(testData, try multiCodec.decode().1)
    }
}
