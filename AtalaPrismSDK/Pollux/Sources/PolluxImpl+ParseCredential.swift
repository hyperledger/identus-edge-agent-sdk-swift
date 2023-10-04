import Domain
import Foundation

extension PolluxImpl {
    public func parseCredential(issuedCredential: Message, options: [CredentialOperationsOptions]) async throws -> Credential {
        guard let issuedAttachment = issuedCredential.attachments.first else {
            throw PolluxError.unsupportedIssuedMessage
        }
        
        switch issuedAttachment.format {
        case "jwt", "", "prism/jwt", .none:
            switch issuedAttachment.data {
            case let json as AttachmentJsonData:
                return try ParseJWTCredentialFromMessage.parse(issuerCredentialData: json.data)
            case let base64 as AttachmentBase64:
                return try ParseJWTCredentialFromMessage.parse(issuerCredentialData: try base64.decoded())
            default:
                throw PolluxError.unsupportedIssuedMessage
            }
        case "anoncreds", "prism/anoncreds", "anoncreds/credential@v1.0":
            guard
                let linkSecretOption = options.first(where: {
                    if case .linkSecret = $0 { return true }
                    return false
                }),
                case let CredentialOperationsOptions.linkSecret(_, secret: linkSecret) = linkSecretOption
            else {
                throw PolluxError.invalidPrismDID
            }

            guard
                let credDefinitionDownloaderOption = options.first(where: {
                    if case .credentialDefinitionDownloader = $0 { return true }
                    return false
                }),
                case let CredentialOperationsOptions.credentialDefinitionDownloader(downloader) = credDefinitionDownloaderOption
            else {
                throw PolluxError.invalidPrismDID
            }

            switch issuedAttachment.data {
            case let json as AttachmentJsonData:
                return try await ParseAnoncredsCredentialFromMessage.parse(
                    issuerCredentialData: json.data,
                    linkSecret: linkSecret,
                    credentialDefinitionDownloader: downloader
                )
            case let base64 as AttachmentBase64:
                return try await ParseAnoncredsCredentialFromMessage.parse(
                    issuerCredentialData: try base64.decoded(),
                    linkSecret: linkSecret,
                    credentialDefinitionDownloader: downloader
                )
            default:
                throw PolluxError.unsupportedIssuedMessage
            }
        default:
            throw PolluxError.invalidCredentialError
        }
    }
}
