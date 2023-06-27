import Domain
import Foundation

extension JWTCredential: ProvableCredential {
    func presentation(request: Message, options: [CredentialOperationsOptions]) throws -> String {
        try JWTPresentation().createPresentation(
            credential: self,
            request: request,
            options: options
        )
    }
}
