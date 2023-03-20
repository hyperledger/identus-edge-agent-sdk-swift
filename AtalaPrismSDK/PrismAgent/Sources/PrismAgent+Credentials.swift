import Core
import Combine
import Domain
import Foundation
import SwiftJWT

// MARK: Verifiable credentials functionalities
public extension PrismAgent {
    /// This function returns the verifiable credentials stored in pluto database
    ///
    /// - Returns:  A publisher that emits an array of `VerifiableCredential` and completes when all the
    ///              credentials are emitted or terminates with an error if any occurs
    func verifiableCredentials() -> AnyPublisher<[VerifiableCredential], Error> {
        pluto.getAllCredentials()
    }

    /// This function parses an issued credential message, stores and returns the verifiable credential.
    ///
    /// - Parameters:
    ///   - message: Issue credential Message.
    /// - Returns: The parsed verifiable credential.
    /// - Throws: PrismAgentError, if there is a problem parsing the credential.
    func processIssuedCredentialMessage(message: IssueCredential) async throws -> VerifiableCredential {
        guard
            let attachment = message.attachments.first?.data as? AttachmentBase64,
            let jwtData = Data(fromBase64URL: attachment.base64),
            let jwtString = String(data: jwtData, encoding: .utf8)
        else {
            throw UnknownError.somethingWentWrongError(
                customMessage: "Cannot find attachment base64 in message",
                underlyingErrors: nil
            )
        }

        let credential = try pollux.parseVerifiableCredential(jwtString: jwtString)
        print(credential)
        try await pluto
            .storeCredential(credential: credential)
            .first()
            .await()
        return credential
    }

    /// This function prepares a request credential from an offer given the subject DID.
    ///
    /// - Parameters:
    ///   - did: Subject DID.
    ///   - did: Received offer credential.
    /// - Returns: Created request credential
    /// - Throws: PrismAgentError, if there is a problem creating the request credential.
    func prepareRequestCredentialWithIssuer(did: DID, offer: OfferCredential) async throws -> RequestCredential? {
        guard did.method == "prism" else { throw PolluxError.invalidPrismDID }
        let apollo = self.apollo
        let seed = self.seed
        let keyPair = try await pluto
            .getPrismDIDInfo(did: did)
            .tryMap {
                guard let info = $0 else { throw PrismAgentError.cannotFindDIDKeyPairIndex }
                return try apollo.createKeyPair(seed: seed, curve: .secp256k1(index: info.keyPairIndex))
            }
            .first()
            .await()

        print(did.string)
        guard
            let pem = apollo.keyDataToPEMString(keyPair.privateKey)?.data(using: .utf8)
        else { throw PrismAgentError.cannotFindDIDKeyPairIndex }

        guard let offerData = offer
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
        let jsonObject = try JSONSerialization.jsonObject(with: offerData)
        guard
            let domain = findValue(forKey: "domain", in: jsonObject),
            let challenge = findValue(forKey: "challenge", in: jsonObject)
        else { throw PrismAgentError.offerDoesntProvideEnoughInformation }

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
        let jwtString = try JWTEncoder(jwtSigner: .es256k(privateKey: pem)).encodeToString(jwt)

        guard let base64String = jwtString.data(using: .utf8)?.base64EncodedString() else {
            throw UnknownError.somethingWentWrongError()
        }
        let requestCredential = RequestCredential(
            body: .init(
                goalCode: offer.body.goalCode,
                comment: offer.body.comment,
                formats: offer.body.formats
            ),
            attachments: [.init(
                mediaType: "prism/jwt",
                data: AttachmentBase64(base64: base64String)
            )],
            thid: offer.thid,
            from: offer.to,
            to: offer.from
        )
        print(requestCredential)
        return requestCredential
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
