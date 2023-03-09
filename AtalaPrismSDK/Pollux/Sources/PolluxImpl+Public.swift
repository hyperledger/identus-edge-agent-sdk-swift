import Core
import Domain
import Foundation

extension PolluxImpl: Pollux {
    public func parseVerifiableCredential(jwtString: String) throws -> VerifiableCredential {
        var jwtParts = jwtString.components(separatedBy: ".")
        guard jwtParts.count == 3 else { throw PolluxError.invalidJWTString }
        jwtParts.removeFirst()
        guard
            let credentialString = jwtParts.first,
            let base64Data = Data(fromBase64URL: credentialString),
            let jsonString = String(data: base64Data, encoding: .utf8)
        else { throw PolluxError.invalidJWTString }

        guard let dataValue = jsonString.data(using: .utf8) else { throw PolluxError.invalidCredentialError }
        if
            let jwtCredential = try? JWTCredential(
                id: jwtString,
                fromJson: dataValue,
                decoder: JSONDecoder()
            ).makeVerifiableCredential()
        {
            return jwtCredential
        } else if let w3cCredential = try? JSONDecoder().decode(W3CVerifiableCredential.self, from: dataValue) {
            return w3cCredential
        } else {
            throw PolluxError.invalidCredentialError
        }
    }

    public func createVerifiablePresentationJWT(credential: VerifyJWTCredential) throws -> String {
        let presentation = JWTCredentialPayload
    }
}
