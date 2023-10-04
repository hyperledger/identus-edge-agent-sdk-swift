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
    func processIssuedCredentialMessage(message: IssueCredential3_0) async throws -> Credential {
        guard
            let linkSecret = try await pluto.getLinkSecret().first().await().first
        else { throw PrismAgentError.cannotFindDIDKeyPairIndex }
        
        let downloader = DownloadDataWithResolver(castor: castor)
        let credential = try await pollux.parseCredential(
            issuedCredential: message.makeMessage(),
            options: [
                .linkSecret(id: "", secret: linkSecret),
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
    /// - Throws: PrismAgentError, if there is a problem creating the request credential.
    func prepareRequestCredentialWithIssuer(did: DID, offer: OfferCredential3_0) async throws -> RequestCredential3_0? {
        guard did.method == "prism" else { throw PolluxError.invalidPrismDID }
        let didInfo = try await pluto
            .getDIDInfo(did: did)
            .first()
            .await()

        guard let storedPrivateKey = didInfo?.privateKeys.first else { throw PrismAgentError.cannotFindDIDKeyPairIndex }

        let privateKey = try await apollo.restorePrivateKey(storedPrivateKey)

        guard
            let exporting = privateKey.exporting,
            let linkSecret = try await pluto.getLinkSecret().first().await().first
        else { throw PrismAgentError.cannotFindDIDKeyPairIndex }
        
        let downloader = DownloadDataWithResolver(castor: castor)
        let requestString = try await pollux.processCredentialRequest(
            offerMessage: offer.makeMessage(),
            options: [
                .exportableKey(exporting),
                .subjectDID(did),
                .linkSecret(id: did.string, secret: linkSecret),
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
            throw PrismAgentError.invalidMessageType(
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
        case "anoncreds/credential-offer@v1.0":
            format = "anoncreds/credential-request@v1.0"
        default:
            throw PrismAgentError.invalidMessageType(
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
