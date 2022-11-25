public protocol DIDResolverDomain {
    func resolve(did: DID) async throws -> DIDDocument
}
