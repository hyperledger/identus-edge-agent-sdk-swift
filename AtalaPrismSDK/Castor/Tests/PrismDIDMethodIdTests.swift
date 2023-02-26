@testable import Castor
import XCTest

final class PrismDIDMethodIdTests: XCTestCase {
    func testSectionsValidation() throws {
        let validation1 = ["aggh123dgasj_-ddadsd", "adbadhj21231_-:0wqebnma"]
        let validation2 = ["aggh12@3dgasj_-ddadsd", "adbadhj21231_-"]
        let validation3 = ["aggh1/23dgasj_-ddadsd", "adbadhj21231_-"]
        let validation4 = ["aggh1+23dgasj_-ddadsd", "adbadhj21231_-"]

        XCTAssertThrowsError(try PrismDIDMethodId(sections: validation1))
        XCTAssertThrowsError(try PrismDIDMethodId(sections: validation2))
        XCTAssertThrowsError(try PrismDIDMethodId(sections: validation3))
        XCTAssertThrowsError(try PrismDIDMethodId(sections: validation4))
    }
}
