import Combine
import CoreData
import Domain

extension CDCredentialDAO: CredentialProvider {
    func getAll() -> AnyPublisher<[StorableCredential], Error> {
        fetchController(context: readContext)
            .tryMap {
                try $0.map { try $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }

    func getCredential(id: String) -> AnyPublisher<StorableCredential?, Error> {
        fetchByIDsPublisher(id, context: readContext)
            .tryMap { try $0?.toDomain() }
            .eraseToAnyPublisher()
    }

    func getBySchema(schema: String) -> AnyPublisher<[StorableCredential], Error> {
        fetchByKeyValuePublisher(key: "schemaId", value: schema, context: readContext)
            .tryMap { try $0.map { try $0.toDomain() } }
            .eraseToAnyPublisher()
    }
}

extension CDCredential {
    func toDomain() throws -> StorableCredential {
        StoringCredential(
            storingId: self.storingId,
            recoveryId: self.recoveryId,
            credentialData: self.credentialData,
            queryIssuer: self.queryIssuer,
            querySubject: self.querySubject,
            queryCredentialCreated: self.queryCredentialCreated,
            queryCredentialUpdated: self.queryCredentialUpdated,
            queryCredentialSchema: self.queryCredentialSchema,
            queryValidUntil: self.queryValidUntil,
            queryRevoked: self.queryRevoked?.boolValue,
            queryAvailableClaims: self.queryAvailableClaims.map(\.value)
        )
    }
}
