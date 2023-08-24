import Combine
import Domain
import Foundation
import SwiftJWT

private struct Schema: Codable {
    let name: String
    let version: String
    let attrNames: [String]
    let issuerId: String
}

struct CreateJWTCredentialRequest {
    static func create(didStr: String, pem: Data, offerData: Data) throws -> String {
        let jsonObject = try JSONSerialization.jsonObject(with: offerData)
        guard
            let domain = findValue(forKey: "domain", in: jsonObject),
            let challenge = findValue(forKey: "challenge", in: jsonObject)
        else { throw PolluxError.offerDoesntProvideEnoughInformation }
        
        let jwt = JWT(claims: ClaimsRequestSignatureJWT(
            iss: didStr,
            aud: domain,
            nonce: challenge,
            vp: .init(context: .init([
                "https://www.w3.org/2018/presentations/v1"
            ]), type: .init([
                "VerifiablePresentation"
            ]))
        ))
        
        return try JWTEncoder(jwtSigner: .es256k(privateKey: pem)).encodeToString(jwt)
    }
}

private struct ClaimsRequestSignatureJWT: Claims {
    struct VerifiablePresentation: Codable {
        enum CodingKeys: String, CodingKey {
            case context = "@context"
            case type = "type"
        }

        let context: Set<String>
        let type: Set<String>
    }

    let iss: String
    let aud: String
    let nonce: String
    let vp: VerifiablePresentation
}


// TODO: This function is not the most appropriate but will do the job now to change later.
func findValue(forKey key: String, in json: Any) -> String? {
    if let dict = json as? [String: Any] {
        if let value = dict[key] {
            return value as? String
        }
        for (_, subJson) in dict {
            if let foundValue = findValue(forKey: key, in: subJson) {
                return foundValue
            }
        }
    } else if let array = json as? [Any] {
        for subJson in array {
            if let foundValue = findValue(forKey: key, in: subJson) {
                return foundValue
            }
        }
    }
    return nil
}
