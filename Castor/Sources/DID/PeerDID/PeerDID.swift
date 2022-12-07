import Domain
import Foundation
import Multibase

struct PeerDID {
    struct Service: Codable {
        enum CodingKeys: String, CodingKey {
            case type = "t"
            case serviceEndpoint = "s"
            case routingKeys = "r"
            case accept = "a"
        }

        let type: String
        let serviceEndpoint: String
        let routingKeys: [String]
        let accept: [String]

        init(
            type: String,
            serviceEndpoint: String,
            routingKeys: [String],
            accept: [String]
        ) {
            self.type = type
            self.serviceEndpoint = serviceEndpoint
            self.routingKeys = routingKeys
            self.accept = accept
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(
                type.replacingOccurrences(of: "DIDCommMessaging", with: "dm"),
                forKey: .type
            )
            try container.encode(serviceEndpoint, forKey: .serviceEndpoint)
            try container.encode(routingKeys, forKey: .routingKeys)
            try container.encode(accept, forKey: .accept)
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            self.type = type == "dm" ? "DIDCommMessaging" : type
            self.serviceEndpoint = try container.decode(String.self, forKey: .serviceEndpoint)
            self.routingKeys = try container.decode([String].self, forKey: .routingKeys)
            self.accept = try container.decode([String].self, forKey: .accept)
        }
    }

    init(did: DID) throws {
        let regex = """
(([01](z)([1-9a-km-zA-HJ-NP-Z]{46,47}))|(2((\\.[AEVID](z)([1-9a-km-zA-HJ-NP-Z]{46,47}))+(\\.(S)[0-9a-zA-Z=]*)?)))$
"""
        guard
            did.schema == "did",
            did.method == "peer",
            did.methodId.range(of: regex, options: .regularExpression) != nil
        else { throw CastorError.invalidPeerDIDError }
        self.did = did
    }

    let did: DID
}
