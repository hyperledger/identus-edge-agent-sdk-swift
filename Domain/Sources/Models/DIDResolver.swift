public protocol DIDResolver {
    func resolve(did: DID) throws -> DIDDocument
}
