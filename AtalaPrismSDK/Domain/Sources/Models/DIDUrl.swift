/// Represents a DIDUrl with "did", "path", "parameters", "fragment"
/// As specified in [w3 standards](`https://www.w3.org/TR/did-core/#dfn-did-urls`)
public struct DIDUrl {
    /// The associated Decentralized Identifier (DID).
    public let did: DID

    /// The path component of the DIDUrl.
    /// An array of string fragments representing the path segments.
    public let path: [String]

    /// The parameters component of the DIDUrl.
    /// A dictionary mapping parameter keys to their associated values.
    public let parameters: [String: String]

    /// The fragment component of the DIDUrl.
    /// An optional string representing the fragment.
    public let fragment: String?

    /// Initializes a new `DIDUrl` with the given components.
    /// - Parameters:
    ///   - did: The associated Decentralized Identifier (DID).
    ///   - path: An array of string fragments representing the path segments.
    ///   - parameters: A dictionary mapping parameter keys to their associated values.
    ///   - fragment: An optional string representing the fragment.
    public init(
        did: DID,
        path: [String] = [],
        parameters: [String: String] = [:],
        fragment: String? = nil
    ) {
        self.did = did
        self.path = path
        self.parameters = parameters
        self.fragment = fragment
    }

    /// A string representation of this `DIDUrl`.
    public var string: String {
        did.string + pathString + queryString + fragmentString
    }

    /// A string representation of the path component of this `DIDUrl`.
    private var pathString: String {
        path.isEmpty ? "" : "/" + path.joined(separator: "/")
    }

    /// A string representation of the parameters component of this `DIDUrl`.
    private var queryString: String {
        parameters.isEmpty ? "" : "?" + parameters.map { $0.key + "=" + $0.value }.joined(separator: "&")
    }

    /// A string representation of the fragment component of this `DIDUrl`.
    private var fragmentString: String {
        fragment.map { "#" + $0 } ?? ""
    }
}
