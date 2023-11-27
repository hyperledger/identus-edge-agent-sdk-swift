import Foundation

struct AnonCredentialSchema: Codable {
    let name: String
    let version: String
    let attrNames: [String]
    let issuerId: String
}
