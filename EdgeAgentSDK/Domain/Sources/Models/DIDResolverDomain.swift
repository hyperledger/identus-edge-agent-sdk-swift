/// The `DIDResolverDomain` protocol defines the interface for resolving DID documents using a specific DID method. Implementations of this protocol provide a `resolve` method that can be used to retrieve the DID document for a given DID.
public protocol DIDResolverDomain {
    /// The DID method associated with this resolver.
    var method: DIDMethod { get }

    /// Resolves the DID document for the given DID.
    /// - Parameter did: The DID to resolve.
    /// - Throws: An error if the DID document cannot be resolved for any reason.
    /// - Returns: The resolved DID document.
    func resolve(did: DID) async throws -> DIDDocument
}
