import Foundation

public typealias DIDMethod = String
public typealias DIDMethodId = String

/// Represents a DID with ``DIDMethod`` and ``DIDMethodId``
/// As specified in [w3 standards](https://www.w3.org/TR/did-core/#dfn-did-schemes)
public struct DID: Equatable {
    public let schema: String
    public let method: DIDMethod
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
    public var string: String { "\(schema):\(method):\(methodId)" }
}
