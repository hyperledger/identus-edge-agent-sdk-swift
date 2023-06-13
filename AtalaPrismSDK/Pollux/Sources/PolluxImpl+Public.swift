import Core
import Domain
import Foundation
import SwiftJWT

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

    public func createVerifiablePresentationJWT(
        did: DID,
        privateKey: PrivateKey & SignableKey,
        credential: VerifiableCredential,
        challenge: String,
        domain: String
    ) async throws -> String {
        guard
            let credentialJWT = (credential as? JWTCredentialPayload)?.originalJWTString
        else { throw PolluxError.invalidJWTCredential }
        let presentation = VerifiablePresentationPayload(
            iss: did.string,
            aud: domain,
            nonce: challenge,
            vp: [
                .init(
                    context: Set(["https://www.w3.org/2018/presentations/v1"]),
                    type: Set(["VerifiablePresentation"]),
                    verifiableCredential: [credentialJWT]
                )
            ]
        )
        let jwt = JWT(header: .init(), claims: presentation)
        let signer = JWTSigner.none
        let withoutSignature = try JWTEncoder(jwtSigner: signer).encodeToString(jwt)
        let signature = try await privateKey.sign(data: withoutSignature.data(using: .utf8)!)
        let signatureBase64 = signature.raw.base64UrlEncodedString()
        let jwtString = withoutSignature + "." + signatureBase64
        return jwtString
    }
}
