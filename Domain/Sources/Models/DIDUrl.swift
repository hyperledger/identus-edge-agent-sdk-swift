/// Represents a DIDUrl with "did", "path", "parameters", "fragment"
/// As specified in [w3 standards](`https://www.w3.org/TR/did-core/#dfn-did-urls`)
public struct DIDUrl {
    /// The associated DID.
    public let did: DID

    /// The path component of the DIDUrl.
    public let path: [String]

    /// The parameters component of the DIDUrl.
    public let parameters: [String: String]

    /// The fragment component of the DIDUrl.
    public let fragment: String?

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

    public var string: String {
        did.string + fragmentString
    }

    private var pathString: String {
        "/" + path.joined(separator: "/")
    }

    private var queryString: String {
        "?" + parameters.map { $0 + "=" + $1 }.joined(separator: "&")
    }

    private var fragmentString: String {
        fragment.map { "#" + $0 } ?? ""
    }
}
