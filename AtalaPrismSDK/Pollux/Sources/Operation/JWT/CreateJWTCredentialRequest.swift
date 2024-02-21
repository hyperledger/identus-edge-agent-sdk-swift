import Combine
import Domain
import Foundation
import JSONWebToken
import JSONWebSignature

private struct Schema: Codable {
    let name: String
    let version: String
    let attrNames: [String]
    let issuerId: String
}

struct CreateJWTCredentialRequest {
    static func create(didStr: String, key: ExportableKey, offerData: Data) throws -> String {
        let jsonObject = try JSONSerialization.jsonObject(with: offerData)
        guard
            let domain = findValue(forKey: "domain", in: jsonObject),
            let challenge = findValue(forKey: "challenge", in: jsonObject)
        else { throw PolluxError.offerDoesntProvideEnoughInformation }
        
        let keyJWK = key.jwk
        
        let jwt = try JWT.signed(
            payload: ClaimsRequestSignatureJWT(
                issuer: didStr,
                subject: nil,
                audience: [domain],
                expirationTime: nil,
                notBeforeTime: nil,
                issuedAt: nil,
                jwtID: nil,
                nonce: challenge,
                vp: .init(context: .init([
                    "https://www.w3.org/2018/presentations/v1"
                ]), type: .init([
                    "VerifiablePresentation"
                ]))
            ),
            protectedHeader: DefaultJWSHeaderImpl(algorithm: .ES256K),
            key: .init(
                keyType: .init(rawValue: keyJWK.kty)!,
                keyID: keyJWK.kid,
                x: keyJWK.x.flatMap { Data(fromBase64URL: $0) },
                y: keyJWK.y.flatMap { Data(fromBase64URL: $0) },
                d: keyJWK.d.flatMap { Data(fromBase64URL: $0) }
            )
        )
        
        // We need to do for now this process so the signatures of secp256k1 Bitcoin can be verified by Bouncy castle
        let jwtString = jwt.jwtString
        var components = jwtString.components(separatedBy: ".")
        guard
            let signature = components.last,
            let signatureData = Data(fromBase64URL: signature)
        else {
            return jwtString
        }

        let (r, s) = extractRS(from: signatureData)
        let fipsSignature = (Data(r.reversed()) + Data(s.reversed())).base64UrlEncodedString()
        _ = components.removeLast()
        return (components + [fipsSignature]).joined(separator: ".")
    }
}

struct ClaimsRequestSignatureJWT: JWTRegisteredFieldsClaims {
    struct VerifiablePresentation: Codable {
        enum CodingKeys: String, CodingKey {
            case context = "@context"
            case type = "type"
        }

        let context: Set<String>
        let type: Set<String>
    }

    let issuer: String?
    let subject: String?
    let audience: [String]?
    let expirationTime: Date?
    let notBeforeTime: Date?
    let issuedAt: Date?
    let jwtID: String?
    let nonce: String
    let vp: VerifiablePresentation
    
    func validateExtraClaims() throws {}

    enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case subject = "sub"
        case audience = "aud"
        case expirationTime = "exp"
        case notBeforeTime = "nbf"
        case issuedAt = "iat"
        case jwtID = "jti"
        case nonce
        case vp
    }
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

private func extractRS(from signature: Data) -> (r: Data, s: Data) {
    let rIndex = signature.startIndex
    let sIndex = signature.index(rIndex, offsetBy: 32)
    let r = signature[rIndex..<sIndex]
    let s = signature[sIndex..<signature.endIndex]
    return (r, s)
}
