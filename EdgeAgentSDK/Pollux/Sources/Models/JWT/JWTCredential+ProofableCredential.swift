import Domain
import Foundation
import JSONWebToken

extension JWTCredential: ProvableCredential {
    public func presentation(request: Message, options: [CredentialOperationsOptions]) throws -> String {
        try JWTPresentation().createPresentation(
            credential: self,
            request: request,
            options: options
        )
    }

    public func isValidForPresentation(request: Message, options: [CredentialOperationsOptions]) throws -> Bool {
        guard
            let attachment = request.attachments.first
        else {
            throw PolluxError.couldNotFindPresentationInAttachments
        }

        let jsonData: Data
        switch attachment.data {
        case let attchedData as AttachmentBase64:
            jsonData = Data(fromBase64URL: attchedData.base64)!
        case let attchedData as AttachmentJsonData:
            jsonData = try JSONEncoder.didComm().encode(attchedData.json)
        default:
            throw PolluxError.invalidAttachmentType(supportedTypes: ["Json", "Base64"])
        }

        switch attachment.format {
        case "dif/presentation-exchange/definitions@v1.0":
            let requestData = try JSONDecoder.didComm().decode(PresentationExchangeRequest.self, from: jsonData)
            let payload: Data = try JWT.getPayload(jwtString: jwtString)
            do {
                try VerifyPresentationSubmissionJWT.verifyPresentationSubmissionClaims(
                    request: requestData.presentationDefinition, credentials: [payload]
                )
                return true
            } catch {
                return false
            }
        case "prism/jwt", "jwt":
            return true
        default:
            throw PolluxError.unsupportedAttachmentFormat(attachment.format)
        }
    }
}
