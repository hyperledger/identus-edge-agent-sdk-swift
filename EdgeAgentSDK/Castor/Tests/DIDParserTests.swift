@testable import Domain
import XCTest

final class DIDParserTests: XCTestCase {
    func testValidDIDs() throws {
        let didExample1 = "did:aaaaaa:aa:aaa"
        let didExample2 = "did:prism01:b2.-_%11:b4._-%11"
        let didExample3 = "did:prism:b6c0c33d701ac1b9a262a14454d1bbde3d127d697a76950963c5fd930605:Cj8KPRI7CgdtYXN0ZXIwEAFKLgoJc2VmsxEiECSTjyV7sUfCr_ArpN9rvCwR9fRMAhcsr_S7ZRiJk4p5k"

        let parsedDID1 = try DID(string: didExample1)
        let parsedDID2 = try DID(string: didExample2)
        let parsedDID3 = try DID(string: didExample3)

        XCTAssertEqual(parsedDID1.schema, "did")
        XCTAssertEqual(parsedDID1.method, "aaaaaa")
        XCTAssertEqual(parsedDID1.methodId, "aa:aaa")

        XCTAssertEqual(parsedDID2.schema, "did")
        XCTAssertEqual(parsedDID2.method, "prism01")
        XCTAssertEqual(parsedDID2.methodId, "b2.-_%11:b4._-%11")

        XCTAssertEqual(parsedDID3.schema, "did")
        XCTAssertEqual(parsedDID3.method, "prism")
        XCTAssertEqual(parsedDID3.methodId, "b6c0c33d701ac1b9a262a14454d1bbde3d127d697a76950963c5fd930605:Cj8KPRI7CgdtYXN0ZXIwEAFKLgoJc2VmsxEiECSTjyV7sUfCr_ArpN9rvCwR9fRMAhcsr_S7ZRiJk4p5k")
    }

    func testInvalidDIDs() throws {
        let didExample1 = "idi:aaaaaa:aa:aaa"
        let didExample2 = "did:-prism-:aaaaa:aaaa"
        let didExample3 = "did:prism:aaaaaaaaaaa::"
        let didExample4 = "did::prism:aaaaaaaaaaa:aaaa"
        let didExample5 = "did:prism::aaaaaaaaaaa:aaaa"

        XCTAssertThrowsError(try DID(string: didExample1))
        XCTAssertThrowsError(try DID(string: didExample2))
        XCTAssertThrowsError(try DID(string: didExample3))
        XCTAssertThrowsError(try DID(string: didExample4))
        XCTAssertThrowsError(try DID(string: didExample5))
    }
}
