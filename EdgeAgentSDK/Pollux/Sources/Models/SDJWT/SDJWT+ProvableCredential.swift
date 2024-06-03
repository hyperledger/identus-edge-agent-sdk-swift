import Domain
import Foundation

extension SDJWTCredential: ProvableCredential {
    func presentation(request: Domain.Message, options: [Domain.CredentialOperationsOptions]) throws -> String {
        try SDJWTPresentation().createPresentation(
            credential: self,
            request: request, 
            options: options
        )
    }
    
    func isValidForPresentation(request: Domain.Message, options: [Domain.CredentialOperationsOptions]) throws -> Bool {
        request.attachments.first.map { $0.format == "vc+sd-jwt"} ?? true
    }
}
