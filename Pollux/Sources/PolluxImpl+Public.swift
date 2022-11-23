import Domain
import Foundation

extension PolluxImpl: Pollux {
    public func parseVerifiableCredential(jsonString: String) throws -> VerifiableCredential {
        guard let dataValue = jsonString.data(using: .utf8) else { throw PolluxError.invalidCredentialError }
        if let jwtCredential = try? JSONDecoder().decode(JWTCredentialPayload.self, from: dataValue)
        {
            return jwtCredential
        } else if let w3cCredential = try? JSONDecoder().decode(W3CVerifiableCredential.self, from: dataValue) {
            return w3cCredential
        } else {
            throw PolluxError.invalidCredentialError
        }
    }
}
