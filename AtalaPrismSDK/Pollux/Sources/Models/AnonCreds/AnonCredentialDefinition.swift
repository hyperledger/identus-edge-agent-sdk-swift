import AnoncredsSwift
import Foundation

struct AnonCredentialDefinition: Codable {
    struct Value: Codable {
        let primary: Primary
    }

    struct Primary: Codable {
        let n: String
        let s: String
        let r: [String: String]
        let rctxt: String
        let z: String
    }
    
    let issuerId: String?
    let schemaId: String
    let type: String
    let tag: String
    let value: Value

    func getAnoncred() throws -> AnoncredsSwift.CredentialDefinition {
        let json = try JSONEncoder().encode(self)
        let jsonString = try json.toString()
        return try .init(jsonString: jsonString)
    }
}
