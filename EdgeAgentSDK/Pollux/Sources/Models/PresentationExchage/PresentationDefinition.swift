import Foundation

/// A protocol defining a format that supports specific types for credential presentation.
public protocol FormatProtocol {
    /// An array of strings representing the types supported by this format.
    var supportedTypes: [String] { get }
}

/// Represents the definition of a presentation request, specifying requirements and formatting options for credential submission.
public struct PresentationDefinition: Codable {
    /// Enumerates rules for how many input credentials need to be submitted.
    public enum Rule: String, Codable {
        case all  // All specified credentials must be submitted.
        case pick // One or more specified credentials must be submitted based on other criteria such as `count`, `min`, or `max`.
    }

    /// Represents requirements for submissions within a presentation definition.
    public struct SubmissionRequirement: Codable {
        /// Optional name for the requirement, useful for identification.
        public let name: String?
        /// Optional purpose describing why the requirement is necessary.
        public let purpose: String?
        /// The rule governing the requirement.
        public let rule: Rule
        /// Specific count of credentials required, if applicable.
        public let count: Int?
        /// Minimum number of credentials required, if applicable.
        public let min: Int?
        /// Maximum number of credentials allowed, if applicable.
        public let max: Int?
        /// Reference to a group or another set of submission requirements.
        public let from: String?
        /// Nested submission requirements.
        public let fromNested: [SubmissionRequirement]?
    }

    /// Represents the format specification for presentation requests, specifying how credentials should be formatted.
    public struct Format: Codable {
        /// Enumerates supported JWT algorithms.
        public enum JWTAlg: String, Codable {
            case EdDSA
            case ES256K
            case ES384
        }

        /// Enumerates supported Linked Data Proof (LDP) types.
        public enum LDPProofType: String, Codable {
            case JsonWebSignature2020 = "JsonWebSignature2020"
            case Ed25519Signature2018 = "Ed25519Signature2018"
            case EcdsaSecp256k1Signature2019 = "EcdsaSecp256k1Signature2019"
            case RsaSignature2018 = "RsaSignature2018"
        }

        /// Represents the JWT format using specific algorithms.
        public struct JWTFormat: FormatProtocol, Codable {
            /// Supported JWT algorithms.
            public let alg: [JWTAlg]
            /// Supported types derived from the JWT algorithms.
            public var supportedTypes: [String] {
                return alg.map { $0.rawValue }
            }

            /// Initializes a new JWT format with the specified algorithms.
            public init(alg: [JWTAlg]) {
                self.alg = alg
            }
        }

        /// Represents the Linked Data Proof (LDP) format using specific proof types.
        public struct LDPFormat: FormatProtocol, Codable {
            /// Supported LDP proof types.
            public let proofType: [LDPProofType]
            /// Supported types derived from the LDP proof types.
            public var supportedTypes: [String] {
                return proofType.map { $0.rawValue }
            }
        }

        /// JWT format specifically for Verifiable Credentials (VC).
        public var jwtVc: JWTFormat?
        /// JWT format specifically for Verifiable Presentations (VP).
        public var jwtVp: JWTFormat?
        /// Generic JWT format.
        public var jwt: JWTFormat?
        /// LDP format specifically for Verifiable Credentials (VC).
        public var ldpVc: LDPFormat?
        /// LDP format specifically for Verifiable Presentations (VP).
        public var ldpVp: LDPFormat?
        /// Generic LDP format.
        public var ldp: LDPFormat?
        /// Generic SDJWT format..
        public var sdJwt: JWTFormat?
    }

    /// Unique identifier for the presentation definition.
    public let id: String
    /// Optional name for the presentation definition.
    public let name: String?
    /// Optional purpose of the presentation request.
    public let purpose: String?
    /// Formatting options for the credential presentation.
    public let format: Format?
    /// Array of submission requirements.
    public let submissionRequirements: [SubmissionRequirement]?
    /// Descriptors defining individual inputs required for the presentation.
    public let inputDescriptors: [InputDescriptor]

    /// Initializes a new `PresentationDefinition` with specified details and requirements.
    /// - Parameters:
    ///   - id: Unique identifier for the definition. Defaults to a new UUID if not specified.
    ///   - name: Optional name for the presentation definition. Useful for referencing and management purposes.
    ///   - purpose: Optional purpose of the presentation request, explaining why the presentation is being requested.
    ///   - format: Optional formatting options for how credentials should be presented, detailing specific format requirements such as JWT or LDP.
    ///   - submissionRequirements: Optional criteria specifying how submissions should be organized and validated, including rules like 'all' or 'pick'.
    ///   - inputDescriptors: Descriptors for each credential input required in the presentation. This array details what credentials are needed and how they should be validated.
    public init(
        id: String = UUID().uuidString,
        name: String? = nil,
        purpose: String? = nil,
        format: Format? = nil,
        submissionRequirements: [SubmissionRequirement]? = nil,
        inputDescriptors: [InputDescriptor] = []
    ) {
        self.id = id
        self.name = name
        self.purpose = purpose
        self.format = format
        self.submissionRequirements = submissionRequirements
        self.inputDescriptors = inputDescriptors
    }
}
