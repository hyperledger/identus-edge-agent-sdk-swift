import Domain
import Foundation
import SwiftJWT

extension PolluxImpl {
    
    private enum SupportedCredential: String {
        case jwt
        case anoncred
    }
    
    public func processCredentialRequest(
        offerMessage: Message,
        options: [CredentialOperationsOptions]
    ) async throws -> String {
        guard let offerAttachment = offerMessage.attachments.first else {
            throw PolluxError.offerDoesntProvideEnoughInformation
        }
        
        switch offerAttachment.mediaType {
        case "jwt", "", .none:
            switch offerAttachment.data {
            case let json as AttachmentJsonData:
                return try processJWTCredentialRequest(offerData: json.data, options: options)
            default:
                throw PolluxError.offerDoesntProvideEnoughInformation
            }
        case "anoncreds":
            switch offerAttachment.data {
            case let json as AttachmentJsonData:
                return try await processAnoncredsCredentialRequest(offerData: json.data, options: options)
            default:
                throw PolluxError.offerDoesntProvideEnoughInformation
            }
        default:
            break
        }
        throw PolluxError.invalidCredentialError
    }

    private func processJWTCredentialRequest(offerData: Data, options: [CredentialOperationsOptions]) throws -> String {
        guard
            let subjectDIDOption = options.first(where: {
                if case .subjectDID = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.subjectDID(did) = subjectDIDOption
        else {
            throw PolluxError.invalidPrismDID
        }
        
        guard
            let exportableKeyOption = options.first(where: {
                if case .exportableKey = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.exportableKey(exportableKey) = exportableKeyOption,
            let pemData = exportableKey.pem.data(using: .utf8)
        else {
            throw PolluxError.requiresExportableKeyForOperation(operation: "Create Credential Request")
        }
        
        return try CreateJWTCredentialRequest.create(didStr: did.string, pem: pemData, offerData: offerData)
    }
    
    private func processAnoncredsCredentialRequest(
        offerData: Data,
        options: [CredentialOperationsOptions]
    ) async throws -> String {
        guard
            let subjectDIDOption = options.first(where: {
                if case .subjectDID = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.subjectDID(did) = subjectDIDOption
        else {
            throw PolluxError.invalidPrismDID
        }
        
        guard
            let linkSecretOption = options.first(where: {
                if case .linkSecret = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.linkSecret(linkSecretId, secret: linkSecret) = linkSecretOption
        else {
            throw PolluxError.invalidPrismDID
        }
        
        guard
            let credentialDefinitonsStreamOption = options.first(where: {
                if case .credentialDefinitionsStream = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.credentialDefinitionsStream(stream) = credentialDefinitonsStreamOption
        else {
            throw PolluxError.invalidPrismDID
        }
        
        return try await CreateAnoncredCredentialRequest.create(
            did: did.string,
            linkSecret: linkSecret,
            linkSecretId: linkSecretId,
            offerData: offerData,
            credentialDefinitions: stream
        )
    }
}
