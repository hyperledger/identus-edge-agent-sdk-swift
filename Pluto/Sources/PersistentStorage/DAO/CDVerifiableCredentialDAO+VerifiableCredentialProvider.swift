import Combine
import CoreData
import Domain

extension CDVerifiableCredentialDAO: VerifiableCredentialProvider {
    func getAll() -> AnyPublisher<[VerifiableCredential], Error> {
        fetchController(context: readContext)
            .tryMap { try $0.map { try $0.toDomain() } }
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
        switch self.credentialId {
        case "jwt":
            return try JSONDecoder()
                .decode(JWTCredentialPayload.self, from: self.verifiableCredetialJson)
        case "w3c":
            return try JSONDecoder()
                .decode(W3CVerifiableCredential.self, from: self.verifiableCredetialJson)
        default:
            throw PlutoError.unknownCredentialTypeError
        }
    }
}
