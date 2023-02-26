import Domain
import Foundation

struct JWTCredential {
    let id: String
    let jwtVerifiableCredential: JWTCredentialPayload

    init(id: String, fromJson: Data, decoder: JSONDecoder) throws {
        self.id = id
        self.jwtVerifiableCredential = try decoder.decode(JWTCredentialPayload.self, from: fromJson)
    }

    func makeVerifiableCredential() -> VerifiableCredential {
        return JWTCredentialPayload(
            iss: jwtVerifiableCredential.iss,
            sub: jwtVerifiableCredential.sub,
            verifiableCredential: jwtVerifiableCredential.verifiableCredential,
            nbf: jwtVerifiableCredential.nbf,
            exp: jwtVerifiableCredential.exp,
            jti: id,
            aud: jwtVerifiableCredential.aud
        )
    }
}
