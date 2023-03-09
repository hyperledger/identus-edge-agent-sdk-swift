import Domain
import Foundation
import SwiftJWT

struct VerifiablePresentationPayload: Claims {

    struct VerifiablePresentation: Codable {
        enum CodingKeys: String, CodingKey {
            case context = "@context"
            case type = "@type"
            case verifiableCredential
        }

        let context: Set<String>
        let type: Set<String>
        let verifiableCredential: [String]
    }

    let iss: String
    let aud: String
    let nonce: String
    let vp: [VerifiablePresentation]
}
