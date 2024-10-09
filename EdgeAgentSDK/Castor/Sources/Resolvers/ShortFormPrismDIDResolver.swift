import DIDCore
import Domain
import Foundation

public struct ShortFormPrismDIDIdentusAgentResolver: DIDResolverDomain {
    struct Response: Codable {
        let didDocument: DIDCore.DIDDocument
    }

    public let method = "prism"
    public let urlBase: URL

    public init(urlBase: URL) {
        self.urlBase = urlBase
    }

    public func resolve(did: Domain.DID) async throws -> Domain.DIDDocument {
        let url: URL
        if #available(iOS 16.0, *) {
             url = urlBase.appending(path: "dids").appending(path: did.string)
        } else {
            url = urlBase.appendingPathComponent("dids").appendingPathComponent(did.string)
        }
        let response = try await URLSession.shared.data(from: url)
        let document = try JSONDecoder().decode(Response.self, from: response.0)
        return try document.didDocument.toDomain()
    }
}
