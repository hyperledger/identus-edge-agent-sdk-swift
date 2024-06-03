import Combine
import Domain
import Foundation
import JSONWebAlgorithms
import JSONWebKey
import JSONWebToken
import JSONWebSignature

private struct Schema: Codable {
    let name: String
    let version: String
    let attrNames: [String]
    let issuerId: String
}

struct CreateJWTCredentialRequest {
    static func create(didStr: String, key: ExportableKey, offerData: Data) async throws -> String {
        let jsonObject = try JSONSerialization.jsonObject(with: offerData)
        guard
            let domain = findValue(forKey: "domain", in: jsonObject),
            let challenge = findValue(forKey: "challenge", in: jsonObject)
        else { throw PolluxError.offerDoesntProvideEnoughInformation }
        
        let keyJWK = key.jwk
        let claims = ClaimsRequestSignatureJWT(
            iss: didStr,
            sub: nil,
            aud: [domain],
            exp: nil,
            nbf: nil,
            iat: nil,
            jti: nil,
            nonce: challenge,
            vp: .init(context: .init([
                "https://www.w3.org/2018/presentations/v1"
            ]), type: .init([
                "VerifiablePresentation"
            ]))
        )

        ES256KSigner.invertedBytesR_S = true

        let jwt = try JWT.signed(
            payload: claims,
            protectedHeader: DefaultJWSHeaderImpl(algorithm: .ES256K),
            key: JSONWebKey.JWK(
                keyType: .init(rawValue: keyJWK.kty)!,
                keyID: keyJWK.kid,
                x: keyJWK.x.flatMap { Data(fromBase64URL: $0) },
                y: keyJWK.y.flatMap { Data(fromBase64URL: $0) },
                d: keyJWK.d.flatMap { Data(fromBase64URL: $0) }
            )
        )

        ES256KSigner.invertedBytesR_S = false
        return jwt.jwtString
    }
}

struct ClaimsRequestSignatureJWT: JWTRegisteredFieldsClaims, Codable {
    struct VerifiablePresentation: Codable {
        enum CodingKeys: String, CodingKey {
            case context = "@context"
            case type = "type"
        }

        let context: Set<String>
        let type: Set<String>
    }

    let iss: String?
    let sub: String?
    let aud: [String]?
    let exp: Date?
    let nbf: Date?
    let iat: Date?
    let jti: String?
    let nonce: String
    let vp: VerifiablePresentation

    func validateExtraClaims() throws {}
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
