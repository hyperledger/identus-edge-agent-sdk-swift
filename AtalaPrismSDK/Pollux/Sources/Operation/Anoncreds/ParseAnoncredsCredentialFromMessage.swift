import AnoncredsSwift
import Foundation

struct ParseAnoncredsCredentialFromMessage {
    static func parse(issuerCredentialData: Data) throws -> AnonCredential {
        try JSONDecoder().decode(AnonCredential.self, from: issuerCredentialData)
    }
}
