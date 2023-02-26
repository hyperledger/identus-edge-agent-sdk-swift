public protocol DIDResolverDomain {
    var method: DIDMethod { get }
    func resolve(did: DID) async throws -> DIDDocument
}
