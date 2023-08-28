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
        let credential = try pollux.parseCredential(issuedCredential: message.makeMessage())
        
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

        guard let storedPrivateKey = didInfo?.privateKeys.first else { throw PrismAgentError.cannotFindDIDKeyPairIndex }

        let privateKey = try await apollo.restorePrivateKey(
            identifier: storedPrivateKey.restorationIdentifier,
            data: storedPrivateKey.storableData
        )

        guard
            let exporting = privateKey.exporting,
            let linkSecret = try await pluto.getLinkSecret().first().await().first
        else { throw PrismAgentError.cannotFindDIDKeyPairIndex }
        
        let requestString = try await pollux.processCredentialRequest(
            offerMessage: try offer.makeMessage(),
            options: [
                .exportableKey(exporting),
                .subjectDID(did),
                .linkSecret(id: did.string, secret: linkSecret),
                .credentialDefinitionsStream(stream: credentialDefinitions),
                .schemasStream(stream: schemas)
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

// TODO: Just while we dont have API for this
extension PrismAgent {
    var credentialDefinitions: AnyPublisher<[(id: String, json: String)], Error> {
        Just([(id: String, json: String)]()).tryMap { $0 }.eraseToAnyPublisher()
    }
    var schemas: AnyPublisher<[(id: String, json: String)], Error> {
        Just([(id: String, json: String)]()).tryMap { $0 }.eraseToAnyPublisher()
    }
}
