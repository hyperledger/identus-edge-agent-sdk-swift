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

    /// Simple initializer that receives a String and returns a DID
    /// - Warning: This is not the preferable way of initializing a DID from a string. Please use `Castor.parseDID(str:)` for uknown strings.
    /// - Parameter string: DID String
    public init(string: String) throws {
        var aux = string.components(separatedBy: ":")
        guard aux.count >= 3 else { throw CastorError.invalidDIDString }
        self.schema = aux.removeFirst()
        self.method = aux.remove(at: 1)
        self.methodId = aux.joined(separator: ":")
    }
}
