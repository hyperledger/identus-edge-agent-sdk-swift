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
    func verifiableCredentials() -> AnyPublisher<[Credential], Error> {
        let pollux = self.pollux
        return pluto.getAllCredentials().tryMap {
            try $0.map {
                try pollux.restoreCredential(
                    restorationIdentifier: $0.recoveryId,
                    credentialData: $0.credentialData
                )
            }
        }
        .eraseToAnyPublisher()
    }

    /// This function parses an issued credential message, stores and returns the verifiable credential.
    ///
    /// - Parameters:
    ///   - message: Issue credential Message.
    /// - Returns: The parsed verifiable credential.
    /// - Throws: PrismAgentError, if there is a problem parsing the credential.
    func processIssuedCredentialMessage(message: IssueCredential) async throws -> Credential {
        guard
            let attachment = message.attachments.first?.data as? AttachmentBase64,
            let data = Data(fromBase64URL: attachment.base64)
        else {
            throw UnknownError.somethingWentWrongError(
                customMessage: "Cannot find attachment base64 in message",
                underlyingErrors: nil
            )
        }

        let credential = try pollux.parseCredential(data: data)
        
        guard let storableCredential = credential.storable else {
            return credential
        }
        try await pluto
            .storeCredential(credential: storableCredential)
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
        let didInfo = try await pluto
            .getDIDInfo(did: did)
            .first()
            .await()

        guard let privateKey = didInfo?.privateKeys.first else { throw PrismAgentError.cannotFindDIDKeyPairIndex }

        guard
            let exporting = privateKey.exporting
        else { throw PrismAgentError.cannotFindDIDKeyPairIndex }
        
        let requestString = try pollux.processCredentialRequest(
            offerMessage: try offer.makeMessage(),
            options: [
                .exportableKey(exporting),
                .subjectDID(did)
            ]
        )

        guard let base64String = requestString.data(using: .utf8)?.base64EncodedString() else {
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
        return requestCredential
    }
}
