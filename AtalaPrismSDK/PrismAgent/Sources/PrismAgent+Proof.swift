import Core
import Combine
import Domain
import Foundation
import Logging
import JSONWebToken

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
        credential: Credential
    ) async throws -> Presentation {
        guard let proofableCredential = credential.proof else {
            throw PrismAgentError.credentialCannotIssuePresentations
        }

        guard let requestType = request.attachments.first?.format else {
            throw PrismAgentError.invalidAttachmentFormat(nil)
        }
        let presentationString: String
        let format: String
        switch requestType {
        case "anoncreds/proof-request@v1.0":
            guard
                let linkSecret = try await pluto.getLinkSecret().first().await()
            else { throw PrismAgentError.cannotFindDIDKeyPairIndex }

            let restored = try await self.apollo.restoreKey(linkSecret)
            guard
                let linkSecretString = String(data: restored.raw, encoding: .utf8)
            else { throw PrismAgentError.cannotFindDIDKeyPairIndex }
            format = "anoncreds/proof@v1.0"
            presentationString = try proofableCredential.presentation(
                request: request.makeMessage(),
                options: [
                    .linkSecret(id: "", secret: linkSecretString)
                ]
            )
        case "prism/jwt", "dif/presentation-exchange/definitions@v1.0":
            guard
                let subjectDIDString = credential.subject
            else {
                throw PolluxError.invalidPrismDID
            }

            let subjectDID = try DID(string: subjectDIDString)

            let privateKeys = try await pluto.getDIDPrivateKeys(did: subjectDID).first().await()

            guard
                let storedPrivateKey = privateKeys?.first
            else { throw PrismAgentError.cannotFindDIDKeyPairIndex }

            let privateKey = try await apollo.restorePrivateKey(storedPrivateKey)

            guard
                let exporting = privateKey.exporting
            else { throw PrismAgentError.cannotFindDIDKeyPairIndex }

            format = requestType == "prism/jwt" ? "prism/jwt" : "dif/presentation-exchange/submission@v1.0"

            presentationString = try proofableCredential.presentation(
                request: request.makeMessage(),
                options: [
                    .exportableKey(exporting),
                    .subjectDID(subjectDID)
                ]
            )
        default:
            throw PrismAgentError.invalidAttachmentFormat(requestType)
        }

        Logger(label: "").log(level: .info, "Presentation: \(presentationString)")

        let base64String = try presentationString.tryToData().base64URLEncoded()

        return Presentation(
            body: .init(
                goalCode: request.body.goalCode,
                comment: request.body.comment
            ),
            attachments: [.init(
                data: AttachmentBase64(base64: base64String),
                format: format
            )],
            thid: request.thid ?? request.id,
            from: request.to,
            to: request.from
        )
    }
}
