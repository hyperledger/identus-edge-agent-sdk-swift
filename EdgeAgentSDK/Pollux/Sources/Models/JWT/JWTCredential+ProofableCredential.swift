import Domain
import Foundation
import JSONWebToken

extension JWTCredential: ProvableCredential {
    public func presentation(request: Message, options: [CredentialOperationsOptions]) throws -> String {
        guard
            let attachment = request.attachments.first,
            let format = attachment.format,
            let requestData = request.attachments.first.flatMap({
                switch $0.data {
                case let json as AttachmentJsonData:
                    return json.data
                case let bas64 as AttachmentBase64:
                    return Data(fromBase64URL: bas64.base64)
                default:
                    return nil
                }
            })
        else {
            throw PolluxError.offerDoesntProvideEnoughInformation
        }
        return try JWTPresentation().createPresentation(
            credential: self,
            type: format,
            requestData: requestData,
            options: options
        )
    }

    public func presentation(
        type: String,
        requestPayload: Data,
        options: [CredentialOperationsOptions]
    ) throws -> String {
        try JWTPresentation().createPresentation(
            credential: self,
            type: type,
            requestData: requestPayload,
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
            jsonData = attchedData.data
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

    public func isValidForPresentation(
        type: String,
        requestPayload: Data,
        options: [CredentialOperationsOptions]
    ) throws -> Bool {
        switch type {
        case "dif/presentation-exchange/definitions@v1.0":
            let requestData = try JSONDecoder.didComm().decode(PresentationExchangeRequest.self, from: requestPayload)
            let payload: Data = try JWT.getPayload(jwtString: jwtString)
            guard
                let format = requestData.presentationDefinition.format?.jwt
            else {
                return false
            }
            do {
                try requestData.presentationDefinition.inputDescriptors.forEach {
                    try VerifyJsonClaim.verify(inputDescriptor: $0, jsonData: payload)
                }
                return true
            } catch {
                return false
            }
        case "prism/jwt", "jwt":
            return true
        default:
            throw PolluxError.unsupportedAttachmentFormat(type)
        }
    }
}
