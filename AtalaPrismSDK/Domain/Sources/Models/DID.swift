import Foundation

/// A type alias representing a DID method (a specific protocol or process used to resolve and manage DIDs) as a string.
public typealias DIDMethod = String

/// A type alias representing a DID method ID (a unique identifier within a DID method) as a string.
public typealias DIDMethodId = String

/// A DID is a unique and persistent identifier for a subject or object, such as a person, organization, or device. It is created and managed using a specific DID method, and consists of a schema, method, and method ID. The schema indicates the type of DID (e.g. "did"), the method indicates the specific protocol or process used to resolve and manage the DID (e.g. "prism"), and the method ID is a unique identifier within the DID method.
/// As specified in the [W3C DID standards](https://www.w3.org/TR/did-core/#dfn-did-schemes).
public struct DID: Equatable {
    /// The schema of the DID (e.g. "did")
    public let schema: String

    /// The method of the DID (e.g. "prism")
    public let method: DIDMethod

    /// The method ID of the DID
    public let methodId: DIDMethodId

    /// Initializes a standard DID
    /// - Parameters:
    ///   - schema: By default it will be `did` as standard.
    ///   - method: DIDMethod specification
    ///   - methodId: DIDMethodId
    public init(
        schema: String = "did",
        method: DIDMethod,
        methodId: DIDMethodId
    ) {
        self.schema = schema
        self.method = method
        self.methodId = methodId
    }

    /// String representation of this DID as specified in [w3 standards](https://www.w3.org/TR/did-core/#dfn-did-schemes)
    /// This is a combination of the schema, method, and method ID, separated by colons (e.g. "did:prism:0xabc123").
    public var string: String { "\(schema):\(method):\(methodId)" }

    /// Simple initializer that receives a String and returns a DID
    /// - Warning: This is not the preferable way of initializing a DID from a string. Please use `Castor.parseDID(str:)` for uknown strings.
    /// - Parameter string: DID String
    public init(string: String) throws {
        var aux = string.components(separatedBy: ":")
        guard aux.count >= 3 else { throw CastorError.invalidDIDString(string) }
        self.schema = aux.removeFirst()
        self.method = aux.removeFirst()
        self.methodId = aux.joined(separator: ":")
    }
}
