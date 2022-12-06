import Combine
import CoreData
import Domain

extension CDVerifiableCredentialDAO: VerifiableCredentialStore {
    func addCredential(credential: VerifiableCredential) -> AnyPublisher<Void, Error> {
        createCDDID(did: credential.issuer)
            .flatMap { did in
                updateOrCreate(credential.id, context: writeContext) { cdobj, _ in
                    try cdobj.parseFromDomain(
                        from: credential,
                        issuer: did,
                        types: Set(),
                        context: Set()
                    )
                }
                .map { _ in }
            }
            .eraseToAnyPublisher()
    }

    func addCredentials(credentials: [VerifiableCredential]) -> AnyPublisher<Void, Error> {
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

    private func createCDDID(did: DID) -> AnyPublisher<CDDID, Error> {
        self.didDAO
            .updateOrCreate(
                did.string,
                context: writeContext
            ) { cdobj, _ in
                cdobj.parseFrom(did: did)
            }
            .map {
                guard let did = self.didDAO.fetchByID($0, context: writeContext) else {
                    // TODO: Replace with a proper error
                    fatalError("This should never happen")
                }
                return did
            }
            .eraseToAnyPublisher()
    }
}

extension CDVerifiableCredential {
    func parseFromDomain(
        from: VerifiableCredential,
        issuer: CDDID,
        types: Set<CDVerifiableCredentialType>,
        context: Set<CDVerifiableCredentialContext>
    ) throws {
        switch from {
        case let jwt as JWTCredentialPayload:
            self.verifiableCredetialJson = try JSONEncoder().encode(jwt)
            self.credentialType = "jwt"
        case let w3c as W3CVerifiableCredential:
            self.verifiableCredetialJson = try JSONEncoder().encode(w3c)
            self.credentialType = "w3c"
        default:
            throw PlutoError.unknownCredentialTypeError
        }
        self.credentialId = from.id
        self.issuanceDate = from.issuanceDate
        self.expirationDate = from.expirationDate
        self.issuer = issuer
        self.type = types
        self.context = context
    }
}
