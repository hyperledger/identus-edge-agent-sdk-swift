import Core
import Domain
import Foundation
import SwiftJWT

extension PolluxImpl: Pollux {
    public func parseCredential(data: Data) throws -> Credential {
        if
            let jwtCredential = try? JWTCredential(data: data)
        {
            return jwtCredential
        } else if let w3cCredential = try? JSONDecoder().decode(W3CVerifiableCredential.self, from: data) {
            return w3cCredential
        }
        
        throw PolluxError.invalidCredentialError
    }
    
    public func restoreCredential(restorationIdentifier: String, credentialData: Data) throws -> Credential {
        switch restorationIdentifier {
        case "jwt+credential":
            return try JSONDecoder().decode(JWTCredential.self, from: credentialData)
        case "w3c+credential":
            return try JSONDecoder().decode(W3CVerifiableCredential.self, from: credentialData)
        default:
            throw PolluxError.invalidCredentialError
        }
    }
    
    public func processCredentialRequest(
        offerMessage: Message,
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
            throw PolluxError.requiresExportableKeyForOperation(operation: "Create Credential Request")
        }
              
        guard let offerData = offerMessage
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
        
        let jsonObject = try JSONSerialization.jsonObject(with: offerData)
        guard
            let domain = findValue(forKey: "domain", in: jsonObject),
            let challenge = findValue(forKey: "challenge", in: jsonObject)
        else { throw PolluxError.offerDoesntProvideEnoughInformation }

        let jwt = JWT(claims: ClaimsRequestSignatureJWT(
            iss: did.string,
            aud: domain,
            nonce: challenge,
            vp: .init(context: .init([
                "https://www.w3.org/2018/presentations/v1"
            ]), type: .init([
                "VerifiablePresentation"
            ]))
        ))

        let jwtString = try JWTEncoder(jwtSigner: .es256k(privateKey: pemData)).encodeToString(jwt)

        return jwtString
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


