import Core
import Combine
import Domain
import Foundation
import SwiftJWT

// MARK: Credentials proof functionalities
public extension PrismAgent {

    /// This function creates a Presentation from a request verfication.
    ///
    /// - Parameters:
    ///   - request: Request message received.
    ///   - credential: Verifiable Credential to present.
    /// - Returns: Presentation message prepared to send.
    /// - Throws: PrismAgentError, if there is a problem creating the presentation.
    func createPresentationForRequestProof(
        request: RequestPresentation,
        credential: VerifiableCredential
    ) async throws -> Presentation {
        guard let requestData = request
            .attachments
            .map({
                switch $0.data {
                case let json as AttachmentJsonData:
                    return json.data
                default:
                    return nil
                }
            })
            .compactMap({ $0 })
            .first
        else { throw PrismAgentError.offerDoesntProvideEnoughInformation }
        let jsonObject = try JSONSerialization.jsonObject(with: requestData)
        guard
            let domain = findValue(forKey: "domain", in: jsonObject),
            let challenge = findValue(forKey: "challenge", in: jsonObject)
        else { throw PrismAgentError.offerDoesntProvideEnoughInformation }

        guard
            let subjectDID = credential.subject
        else {
            throw UnknownError.somethingWentWrongError()
        }

        let didInfo = try await pluto
            .getDIDInfo(did: subjectDID)
            .first()
            .await()

        guard let privateKey = didInfo?.privateKeys.first else { throw PrismAgentError.cannotFindDIDKeyPairIndex }

        guard
            let exporting = privateKey.exporting,
            let pemData = exporting.pem.data(using: .utf8)
        else { throw PrismAgentError.cannotFindDIDKeyPairIndex }

        let jwt = JWT(claims: ClaimsProofPresentationJWT(
            iss: subjectDID.string,
            aud: domain,
            nonce: challenge,
            vp: .init(
                context: .init(["https://www.w3.org/2018/presentations/v1"]),
                type: .init(["VerifiablePresentation"]),
                verifiableCredential: [credential.id]
            )
        ))
        let jwtString = try JWTEncoder(jwtSigner: .es256k(privateKey: pemData)).encodeToString(jwt)
        
        guard let base64String = jwtString.data(using: .utf8)?.base64EncodedString() else {
            throw UnknownError.somethingWentWrongError()
        }
        return Presentation(
            body: .init(
                goalCode: request.body.goalCode,
                comment: request.body.comment
            ),
            attachments: [.init(
                mediaType: "prism/jwt",
                data: AttachmentBase64(base64: base64String)
            )],
            thid: request.thid,
            from: request.to,
            to: request.from
        )
    }
}

// TODO: This function is not the most appropriate but will do the job now to change later.
private func findValue(forKey key: String, in json: Any) -> String? {
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

