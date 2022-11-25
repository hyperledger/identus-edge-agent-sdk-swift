import Domain
import Foundation

extension DID: Codable {
    enum CodingKeys: String, CodingKey {
        case schema
        case method
        case methodId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schema, forKey: .schema)
        try container.encode(method, forKey: .method)
        try container.encode(methodId, forKey: .methodId)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let schema = try container.decode(String.self, forKey: .schema)
        let method = try container.decode(DIDMethod.self, forKey: .method)
        let methodId = try container.decode(DIDMethodId.self, forKey: .methodId)

        self.init(schema: schema, method: method, methodId: methodId)
    }
}
