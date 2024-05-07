import Foundation

struct ParseJWTCredentialFromMessage {
    static func parse(issuerCredentialData: Data) throws -> JWTCredential {
        try JWTCredential(data: issuerCredentialData)
    }
}
