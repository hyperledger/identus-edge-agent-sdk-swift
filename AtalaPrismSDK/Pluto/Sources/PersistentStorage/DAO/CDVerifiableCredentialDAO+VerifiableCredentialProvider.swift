import Combine
import CoreData
import Domain

extension CDVerifiableCredentialDAO: VerifiableCredentialProvider {
    func getAll() -> AnyPublisher<[VerifiableCredential], Error> {
        fetchController(context: readContext)
            .tryMap {
                try $0.map { try $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }

    func getCredential(id: String) -> AnyPublisher<VerifiableCredential?, Error> {
        fetchByIDsPublisher(id, context: readContext)
            .tryMap { try $0?.toDomain() }
            .eraseToAnyPublisher()
    }

    func getBySchema(schema: String) -> AnyPublisher<[VerifiableCredential], Error> {
        fetchByKeyValuePublisher(key: "schemaId", value: schema, context: readContext)
            .tryMap { try $0.map { try $0.toDomain() } }
            .eraseToAnyPublisher()
    }
}

extension CDVerifiableCredential {
    func toDomain() throws -> VerifiableCredential {
        switch self.credentialType {
        case "jwt":
            let credential = try JSONDecoder()
                .decode(JWTCredentialPayload.self, from: self.verifiableCredetialJson)
            return JWTCredentialPayload(
                iss: credential.iss,
                sub: credential.sub,
                verifiableCredential: credential.verifiableCredential,
                nbf: credential.nbf,
                exp: credential.exp,
                jti: credential.jti,
                aud: credential.aud,
                originalJWTString: self.originalJWT
            )
        case "w3c":
            return try JSONDecoder()
                .decode(W3CVerifiableCredential.self, from: self.verifiableCredetialJson)
        default:
            throw PlutoError.unknownCredentialTypeError
        }
    }
}
