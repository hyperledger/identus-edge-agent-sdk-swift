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

        let jwt = JWT(claims: ClaimsProofPresentationJWT(
            iss: did.string,
            aud: domain,
            nonce: challenge,
            vp: .init(
                context: .init(["https://www.w3.org/2018/presentations/v1"]),
                type: .init(["VerifiablePresentation"]),
                verifiableCredential: [credential.jwtString]
            )
        ))
        let jwtString = try JWTEncoder(jwtSigner: .es256k(privateKey: pemData)).encodeToString(jwt)
        return jwtString
    }
}

private struct ClaimsProofPresentationJWT: Claims {
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

    let iss: String
    let aud: String
    let nonce: String
    let vp: VerifiablePresentation
}
