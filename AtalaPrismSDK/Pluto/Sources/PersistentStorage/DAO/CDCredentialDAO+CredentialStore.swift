import Combine
import CoreData
import Domain

extension CDCredentialDAO: CredentialStore {
    func addCredential(credential: StorableCredential) -> AnyPublisher<Void, Error> {
        updateOrCreate(credential.storingId, context: writeContext) { cdobj, context in
            let claimsObjs = credential.queryAvailableClaims.map {
                let obj = CDAvailableClaim(
                    entity: CDAvailableClaim.entity(),
                    insertInto: context
                )
                obj.value = $0
                return obj
            }
            try cdobj.parseFromDomain(
                from: credential,
                withClaims: Set(claimsObjs)
            )
        }
        .map { _ in }
        .eraseToAnyPublisher()
    }

    func addCredentials(credentials: [StorableCredential]) -> AnyPublisher<Void, Error> {
        credentials.publisher.flatMap {
            self.addCredential(credential: $0)
        }
        .map { _ in }
        .eraseToAnyPublisher()
    }

    func removeCredential(id: String) -> AnyPublisher<Void, Error> {
        deleteByIDsPublisher([id], context: writeContext)
    }

    func removeAll() -> AnyPublisher<Void, Error> {
        deleteAllPublisher(context: writeContext)
    }
}

extension CDCredential {
    func parseFromDomain(
        from: StorableCredential,
        withClaims: Set<CDAvailableClaim>
    ) throws {
        self.storingId = from.storingId
        self.recoveryId = from.recoveryId
        self.credentialData = from.credentialData
        self.queryIssuer = from.queryIssuer
        self.querySubject = from.querySubject
        self.queryCredentialCreated = from.queryCredentialCreated
        self.queryCredentialUpdated = from.queryCredentialUpdated
        self.queryCredentialSchema = from.queryCredentialSchema
        self.queryRevoked = from.queryRevoked.map { NSNumber(booleanLiteral: $0) }
        self.queryValidUntil = from.queryValidUntil
        self.queryAvailableClaims = withClaims
    }
}
