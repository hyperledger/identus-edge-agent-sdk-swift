import Core
import Combine
import Domain
import Foundation
import Logging
import JSONWebToken

// MARK: Verifiable credentials functionalities
public extension EdgeAgent {
    /// This function returns the verifiable credentials stored in pluto database
    ///
    /// - Returns:  A publisher that emits an array of `VerifiableCredential` and completes when all the
    ///              credentials are emitted or terminates with an error if any occurs
    func verifiableCredentials() -> AnyPublisher<[Credential], Error> {
        let pollux = self.pollux
        return pluto.getAllCredentials().tryMap {
            $0.compactMap {
                try? pollux.restoreCredential(
                    restorationIdentifier: $0.recoveryId,
                    credentialData: $0.credentialData
                )
            }
        }
        .eraseToAnyPublisher()
    }

    /// This function initiates a presentation request for a specific type of credential, specifying the sender's and receiver's DIDs, and any claim filters applicable.
    ///
    /// - Parameters:
    ///   - type: The type of the credential for which the presentation is requested.
    ///   - fromDID: The decentralized identifier (DID) of the entity initiating the request.
    ///   - toDID: The decentralized identifier (DID) of the entity to which the request is being sent.
    ///   - claimFilters: A collection of filters specifying the claims required in the credential.
    /// - Returns: The initiated request for presentation.
    /// - Throws: EdgeAgentError, if there is a problem initiating the presentation request.
    func initiatePresentationRequest(
        type: CredentialType,
        fromDID: DID,
        toDID: DID,
        claimFilters: [ClaimFilter]
    ) async throws -> RequestPresentation {
        let request = try self.pollux.createPresentationRequest(
            type: type,
            toDID: toDID,
            name: UUID().uuidString,
            version: "1.0",
            claimFilters: claimFilters
        )

        let rqstStr = try request.tryToString()
        logger.debug(message: "Request: \(rqstStr)")
        let attachment: AttachmentDescriptor
        switch type {
        case .jwt:
            let data = AttachmentBase64(base64: request.base64URLEncoded())
            attachment = AttachmentDescriptor(
                mediaType: "application/json",
                data: data,
                format: "dif/presentation-exchange/definitions@v1.0"
            )
        case .anoncred:
            let data = AttachmentBase64(base64: request.base64URLEncoded())
            attachment = AttachmentDescriptor(
                mediaType: "application/json",
                data: data,
                format: "anoncreds/proof-request@v1.0"
            )
        }

        return RequestPresentation(
            body: .init(
                proofTypes: [ProofTypes(
                    schema: "",
                    requiredFields: claimFilters.flatMap(\.paths),
                    trustIssuers: nil
                )]
            ),
            attachments: [attachment],
            thid: nil,
            from: fromDID,
            to: toDID
        )
    }

    /// This function verifies the presentation contained within a message.
    ///
    /// - Parameters:
    ///   - message: The message containing the presentation to be verified.
    /// - Returns: A Boolean value indicating whether the presentation is valid (`true`) or not (`false`).
    /// - Throws: EdgeAgentError, if there is a problem verifying the presentation.

    func verifyPresentation(message: Message) async throws -> Bool {
        do {
            let downloader = DownloadDataWithResolver(castor: castor)
            return try await pollux.verifyPresentation(message: message, options: [
                .credentialDefinitionDownloader(downloader: downloader),
                .schemaDownloader(downloader: downloader)
            ])
        } catch {
            logger.error(error: error)
            throw error
        }
    }

    /// This function parses an issued credential message, stores and returns the verifiable credential.
    ///
    /// - Parameters:
    ///   - message: Issue credential Message.
    /// - Returns: The parsed verifiable credential.
    /// - Throws: EdgeAgentError, if there is a problem parsing the credential.
    func processIssuedCredentialMessage(message: IssueCredential3_0) async throws -> Credential {
        guard
            let linkSecret = try await pluto.getLinkSecret().first().await()
        else { throw EdgeAgentError.cannotFindDIDKeyPairIndex }

        let restored = try await self.apollo.restoreKey(linkSecret)
        guard
            let linkSecretString = String(data: restored.raw, encoding: .utf8)
        else { throw EdgeAgentError.cannotFindDIDKeyPairIndex }

        let downloader = DownloadDataWithResolver(castor: castor)
        let credential = try await pollux.parseCredential(
            issuedCredential: message.makeMessage(),
            options: [
                .linkSecret(id: "", secret: linkSecretString),
                .credentialDefinitionDownloader(downloader: downloader),
                .schemaDownloader(downloader: downloader)
            ]
        )
        
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
    /// - Throws: EdgeAgentError, if there is a problem creating the request credential.
    func prepareRequestCredentialWithIssuer(did: DID, offer: OfferCredential3_0) async throws -> RequestCredential3_0? {
        guard did.method == "prism" else { throw PolluxError.invalidPrismDID }
        let didInfo = try await pluto
            .getDIDInfo(did: did)
            .first()
            .await()

        guard let storedPrivateKey = didInfo?.privateKeys.first else { throw EdgeAgentError.cannotFindDIDKeyPairIndex }

        let privateKey = try await apollo.restorePrivateKey(storedPrivateKey)

        guard
            let exporting = privateKey.exporting,
            let linkSecret = try await pluto.getLinkSecret().first().await()
        else { throw EdgeAgentError.cannotFindDIDKeyPairIndex }

        let restored = try await self.apollo.restoreKey(linkSecret)
        guard
            let linkSecretString = String(data: restored.raw, encoding: .utf8)
        else { throw EdgeAgentError.cannotFindDIDKeyPairIndex }

        let downloader = DownloadDataWithResolver(castor: castor)
        let requestString = try await pollux.processCredentialRequest(
            offerMessage: offer.makeMessage(),
            options: [
                .exportableKey(exporting),
                .subjectDID(did),
                .linkSecret(id: did.string, secret: linkSecretString),
                .credentialDefinitionDownloader(downloader: downloader),
                .schemaDownloader(downloader: downloader)
            ]
        )

        guard
            let offerFormat = offer.attachments.first?.format,
            let base64String = requestString.data(using: .utf8)?.base64EncodedString()
        else {
            throw CommonError.invalidCoding(message: "Could not encode to base64")
        }
        guard
            let offerPiuri = ProtocolTypes(rawValue: offer.type)
        else {
            throw EdgeAgentError.invalidMessageType(
                type: offer.type,
                shouldBe: [
                    ProtocolTypes.didcommOfferCredential3_0.rawValue
                ]
            )
        }
        let format: String
        switch offerFormat {
        case "prism/jwt":
            format = "prism/jwt"
        case "vc+sd-jwt":
            format = "vc+sd-jwt"
        case "anoncreds/credential-offer@v1.0":
            format = "anoncreds/credential-request@v1.0"
        default:
            throw EdgeAgentError.invalidMessageType(
                type: offerFormat,
                shouldBe: [
                    "prism/jwt",
                    "anoncreds/credential-offer@v1.0"
                ]
            )
        }
        
        let type = offerPiuri == .didcommOfferCredential ?
            ProtocolTypes.didcommRequestCredential :
            ProtocolTypes.didcommRequestCredential3_0
        
        let requestCredential = RequestCredential3_0(
            body: .init(
                goalCode: offer.body.goalCode,
                comment: offer.body.comment
            ),
            type: type.rawValue,
            attachments: [.init(
                data: AttachmentBase64(base64: base64String),
                format: format
            )],
            thid: offer.thid,
            from: offer.to,
            to: offer.from
        )
        return requestCredential
    }
}
