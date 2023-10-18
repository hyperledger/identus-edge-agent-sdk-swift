import Domain
import XCTest

final class DIDUrlParserTests: XCTestCase {
    func testValidDIDUrls() throws {
        let didExample1 = "did:example:123456:adsd/path?query=something#fragment"
        let didExample2 = "did:example:123456/path?query=something&query2=something#0"
        let didExample3 = "did:example:123456/path/jpg.pp?query=something"

        let parsedDID1 = try DIDUrl(string: didExample1)
        let parsedDID2 = try DIDUrl(string: didExample2)
        let parsedDID3 = try DIDUrl(string: didExample3)

        XCTAssertEqual(parsedDID1.did.schema, "did")
        XCTAssertEqual(parsedDID1.did.method, "example")
        XCTAssertEqual(parsedDID1.did.methodId, "123456:adsd")
        XCTAssertEqual(parsedDID1.path, ["path"])
        XCTAssertEqual(parsedDID1.parameters, ["query": "something"])
        XCTAssertEqual(parsedDID1.fragment, "fragment")

        XCTAssertEqual(parsedDID2.did.schema, "did")
        XCTAssertEqual(parsedDID2.did.method, "example")
        XCTAssertEqual(parsedDID2.did.methodId, "123456")
        XCTAssertEqual(parsedDID2.path, ["path"])
        XCTAssertEqual(parsedDID2.parameters, ["query": "something", "query2": "something"])
        XCTAssertEqual(parsedDID2.fragment, "0")

        XCTAssertEqual(parsedDID3.did.schema, "did")
        XCTAssertEqual(parsedDID3.did.method, "example")
        XCTAssertEqual(parsedDID3.did.methodId, "123456")
        XCTAssertEqual(parsedDID3.path, ["path", "jpg.pp"])
        XCTAssertEqual(parsedDID3.parameters, ["query": "something"])
        XCTAssertNil(parsedDID3.fragment)
    }
}
