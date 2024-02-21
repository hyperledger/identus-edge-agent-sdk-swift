import Domain
import Foundation
import JSONWebSignature
import JSONWebToken

struct VerifiablePresentationPayload: JWTRegisteredFieldsClaims {
    
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

    let issuer: String?
    let subject: String?
    let audience: [String]?
    let expirationTime: Date?
    let notBeforeTime: Date?
    let issuedAt: Date?
    let jwtID: String?
    let nonce: String
    let vp: [VerifiablePresentation]
    
    func validateExtraClaims() throws {}
}

struct JWTPresentation {
    
    func createPresentation(
        credential: JWTCredential,
        request: Message,
        options: [CredentialOperationsOptions]
    ) throws -> String {
        guard
            let subjectDIDOption = options.first(where: {
                if case .subjectDID = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.subjectDID(did) = subjectDIDOption
        else {
            throw PolluxError.invalidPrismDID
        }
        
        guard
            let exportableKeyOption = options.first(where: {
                if case .exportableKey = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.exportableKey(exportableKey) = exportableKeyOption,
            let pemData = exportableKey.pem.data(using: .utf8)
        else {
            throw PolluxError.requiresExportableKeyForOperation(operation: "Create Presentation JWT Credential")
        }
        
        guard let requestData = request
            .attachments
            .first
            .flatMap({
                switch $0.data {
                case let json as AttachmentJsonData:
                    return json.data
                default:
                    return nil
                }
            })
        else { throw PolluxError.offerDoesntProvideEnoughInformation }
        let jsonObject = try JSONSerialization.jsonObject(with: requestData)
        guard
            let domain = findValue(forKey: "domain", in: jsonObject),
            let challenge = findValue(forKey: "challenge", in: jsonObject)
        else { throw PolluxError.offerDoesntProvideEnoughInformation }
        
        let keyJWK = exportableKey.jwk
        
        let jwt = try JWT.signed(
            payload: ClaimsProofPresentationJWT(
                issuer: did.string,
                subject: nil,
                audience: [domain],
                expirationTime: nil,
                notBeforeTime: nil,
                issuedAt: nil,
                jwtID: nil,
                nonce: challenge,
                vp: .init(
                    context: .init(["https://www.w3.org/2018/presentations/v1"]),
                    type: .init(["VerifiablePresentation"]),
                    verifiableCredential: [credential.jwtString]
                )
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

private struct ClaimsProofPresentationJWT: JWTRegisteredFieldsClaims {
    struct VerifiablePresentation: Codable {
        enum CodingKeys: String, CodingKey {
            case context = "@context"
            case type = "type"
            case verifiableCredential
        }

        let context: Set<String>
        let type: Set<String>
        let verifiableCredential: [String]
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

private func extractRS(from signature: Data) -> (r: Data, s: Data) {
    let rIndex = signature.startIndex
    let sIndex = signature.index(rIndex, offsetBy: 32)
    let r = signature[rIndex..<sIndex]
    let s = signature[sIndex..<signature.endIndex]
    return (r, s)
}
