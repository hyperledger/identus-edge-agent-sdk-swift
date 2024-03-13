import Foundation

/// Represents the types of proofs required for a credential, including the schema, required fields, and trusted issuers.
public struct ProofTypes: Codable, Equatable {
    /// The schema identifier for the proof, defining the structure or standard it adheres to.
    public let schema: String

    /// An optional array of strings that specifies the fields required in the proof. If nil, no specific fields are required.
    public let requiredFields: [String]?

    /// An optional array of strings that lists identifiers of trusted issuers. If nil, there are no restrictions on issuers.
    public let trustIssuers: [String]?

    /// Initializes a new `ProofTypes` with specified schema, required fields, and trusted issuers.
    /// - Parameters:
    ///   - schema: The schema identifier for the proof.
    ///   - requiredFields: Optional. Specific fields required in the proof.
    ///   - trustIssuers: Optional. Trusted issuers required for the proof.
    public init(schema: String, requiredFields: [String]?, trustIssuers: [String]?) {
        self.schema = schema
        self.requiredFields = requiredFields
        self.trustIssuers = trustIssuers
    }
}

/// Represents a filter for credential claims, specifying criteria that claims must meet to be considered valid.
public struct ClaimFilter {
    /// An array of string paths specifying where in a credential's data structure to apply the filter.
    public let paths: [String]

    /// The type of data expected at the specified paths, typically representing a data type like `string`, `number`, etc.
    public let type: String

    /// A Boolean indicating whether the presence of this claim is mandatory.
    public let required: Bool

    /// An optional name for the claim, used for identification or labeling purposes.
    public let name: String?

    /// An optional purpose for the claim, providing context or reasoning for why the claim is needed.
    public let purpose: String?

    /// An optional format specifier for the claim data, such as `date`, `email`, etc., to enforce specific data formats.
    public let format: String?

    /// An optional constant value that the claim must exactly match.
    public let const: String?

    /// An optional regex pattern that the claim data must conform to.
    public let pattern: String?

    /// Initializes a new `ClaimFilter` with the specified properties.
    /// - Parameters:
    ///   - paths: The paths in the credential data to apply the filter.
    ///   - type: The type of data expected at these paths.
    ///   - required: Whether the claim is mandatory.
    ///   - name: Optional. A name for the claim.
    ///   - purpose: Optional. The purpose or context for the claim.
    ///   - format: Optional. A format specifier for the claim data.
    ///   - const: Optional. A constant value the claim must match.
    ///   - pattern: Optional. A regex pattern the claim must conform to.
    public init(
        paths: [String],
        type: String,
        required: Bool = false,
        name: String? = nil,
        purpose: String? = nil,
        format: String? = nil,
        const: String? = nil,
        pattern: String? = nil
    ) {
        self.paths = paths
        self.type = type
        self.required = required
        self.name = name
        self.purpose = purpose
        self.format = format
        self.const = const
        self.pattern = pattern
    }
}
