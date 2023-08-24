import Domain
import Foundation

extension PolluxImpl {
    public func parseCredential(issuedCredential: Message) throws -> Credential {
        guard let issuedAttachment = issuedCredential.attachments.first else {
            throw PolluxError.unsupportedIssuedMessage
        }
        
        switch issuedAttachment.mediaType {
        case "jwt", "", "prism/jwt", .none:
            switch issuedAttachment.data {
            case let json as AttachmentJsonData:
                return try ParseJWTCredentialFromMessage.parse(issuerCredentialData: json.data)
            case let base64 as AttachmentBase64:
                return try ParseJWTCredentialFromMessage.parse(issuerCredentialData: try base64.decoded())
            default:
                throw PolluxError.unsupportedIssuedMessage
            }
        case "anoncreds", "prism/anoncreds":
            switch issuedAttachment.data {
            case let json as AttachmentJsonData:
                return try ParseAnoncredsCredentialFromMessage.parse(issuerCredentialData: json.data)
            case let base64 as AttachmentBase64:
                return try ParseAnoncredsCredentialFromMessage.parse(issuerCredentialData: try base64.decoded())
            default:
                throw PolluxError.unsupportedIssuedMessage
            }
        default:
            throw PolluxError.invalidCredentialError
        }
    }
}
