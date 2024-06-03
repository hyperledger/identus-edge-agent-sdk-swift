import Apollo
import Castor
import Domain
import EdgeAgent
@testable import Pollux
import XCTest

final class SDJWTTests: XCTestCase {

    lazy var apollo = ApolloImpl()
    lazy var castor = CastorImpl(apollo: apollo)

    func testParseSDJWTCredential() throws {
        let validJWTString = "eyJ0eXAiOiJzZCtqd3QiLCJhbGciOiJFUzI1NiJ9.eyJpZCI6IjEyMzQiLCJfc2QiOlsiYkRUUnZtNS1Zbi1IRzdjcXBWUjVPVlJJWHNTYUJrNTdKZ2lPcV9qMVZJNCIsImV0M1VmUnlsd1ZyZlhkUEt6Zzc5aGNqRDFJdHpvUTlvQm9YUkd0TW9zRmsiLCJ6V2ZaTlMxOUF0YlJTVGJvN3NKUm4wQlpRdldSZGNob0M3VVphYkZyalk4Il0sIl9zZF9hbGciOiJzaGEtMjU2In0.n27NCtnuwytlBYtUNjgkesDP_7gN7bhaLhWNL4SWT6MaHsOjZ2ZMp987GgQRL6ZkLbJ7Cd3hlePHS84GBXPuvg~WyI1ZWI4Yzg2MjM0MDJjZjJlIiwiZmlyc3RuYW1lIiwiSm9obiJd~WyJjNWMzMWY2ZWYzNTg4MWJjIiwibGFzdG5hbWUiLCJEb2UiXQ~WyJmYTlkYTUzZWJjOTk3OThlIiwic3NuIiwiMTIzLTQ1LTY3ODkiXQ~"

        let credential = try SDJWTCredential(sdjwtString: validJWTString)
        XCTAssertEqual(credential.claims.map(\.key).sorted(), ["firstname", "lastname", "ssn"].sorted())
        XCTAssertEqual(credential.id, validJWTString)
    }
}
