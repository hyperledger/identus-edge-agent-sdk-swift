import Domain
import Foundation

struct CodableDID: Codable {
    enum CodingKeys: String, CodingKey {
        case schema
        case method
        case methodId
    }

    let did: DID

    init(did: DID) {
        self.did = did
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(did.schema, forKey: .schema)
        try container.encode(did.method, forKey: .method)
        try container.encode(did.methodId, forKey: .methodId)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let schema = try container.decode(String.self, forKey: .schema)
        let method = try container.decode(DIDMethod.self, forKey: .method)
        let methodId = try container.decode(DIDMethodId.self, forKey: .methodId)

        self.init(did: .init(
            schema: schema,
            method: method,
            methodId: methodId
        ))
    }
}
