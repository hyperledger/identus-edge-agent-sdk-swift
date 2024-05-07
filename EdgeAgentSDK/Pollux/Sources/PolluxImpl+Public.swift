import Core
import Domain
import Foundation

extension PolluxImpl: Pollux {
    public func restoreCredential(restorationIdentifier: String, credentialData: Data) throws -> Credential {
        switch restorationIdentifier {
        case "jwt+credential":
            return try JSONDecoder().decode(JWTCredential.self, from: credentialData)
        case "w3c+credential":
            return try JSONDecoder().decode(W3CVerifiableCredential.self, from: credentialData)
        case "anon+credential":
            return try JSONDecoder().decode(AnoncredsCredentialStack.self, from: credentialData)
        default:
            throw PolluxError.invalidCredentialError
        }
    }
}
