import Apollo
@testable import Castor
@testable import Domain
import XCTest

final class ShortFormPrimsDIDResolverTests: XCTestCase {
    func testValidDIDs() async throws {
        let didExample3 = "did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445"

        let resolver = ShortFormPrismDIDIdentusAgentResolver(urlBase: URL(string: "http://localhost:8090")!)
        let document = try await resolver.resolve(did: DID(string: didExample3))
        print(document)
    }
}
