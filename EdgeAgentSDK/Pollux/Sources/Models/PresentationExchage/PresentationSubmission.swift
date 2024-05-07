import Foundation

/// Represents a submission of a presentation in response to a presentation definition.
public struct PresentationSubmission: Codable {
    /// Unique identifier for the submission.
    public let id: String
    /// Identifier of the presentation definition this submission is responding to.
    public let definitionId: String
    /// Map describing how credentials are presented according to the input descriptors from the presentation definition.
    public let descriptorMap: [Descriptor]

    /// Initializes a new `PresentationSubmission` with the specified identifiers and descriptor map.
    /// - Parameters:
    ///   - id: Unique identifier for the submission. Defaults to a new UUID if not specified.
    ///   - definitionId: The identifier of the presentation definition being responded to.
    ///   - descriptorMap: A collection of descriptors explaining how each credential is presented.
    public init(
        id: String = UUID().uuidString,
        definitionId: String,
        descriptorMap: [Descriptor]
    ) {
        self.id = id
        self.definitionId = definitionId
        self.descriptorMap = descriptorMap
    }

    /// Represents a descriptor within a presentation submission, linking presented credentials to the expectations set in the presentation definition.
    public class Descriptor: Codable {
        /// Identifier for this descriptor, typically matching an input descriptor in the presentation definition.
        public let id: String
        /// JSON path within the submitted data where the credential or piece of data can be found.
        public let path: String
        /// Format of the data at this path, specifying how the data should be interpreted.
        public let format: String
        /// Optional nested descriptor for more complex data structures.
        public let pathNested: Descriptor?

        /// Initializes a new `Descriptor` for use within a presentation submission.
        /// - Parameters:
        ///   - id: Unique identifier for the descriptor. Defaults to a new UUID if not specified.
        ///   - path: JSON path to the credential or data in the submission.
        ///   - format: Format of the credential or data at the specified path.
        ///   - pathNested: Optional nested descriptor for complex data structures.
        public init(id: String = UUID().uuidString, path: String, format: String, pathNested: Descriptor? = nil) {
            self.id = id
            self.path = path
            self.format = format
            self.pathNested = pathNested
        }
    }
}

/// Represents requirements for submissions, either directly applying rules or nesting other requirements.
public enum SubmissionRequirement: Codable {
    case directRule(DirectRuleRequirement)
    case nestedRule(NestedRuleRequirement)

    /// Direct rule specifying requirements for submission, including rules for counting or selecting credentials.
    public struct DirectRuleRequirement: Codable {
        public let name: String?
        public let purpose: String?
        public let rule: PresentationDefinition.Rule
        public let count: Int?
        public let min: Int?
        public let max: Int?
        public let from: String
    }

    /// Nested rule that contains other submission requirements, allowing for complex conditions and grouping of requirements.
    public struct NestedRuleRequirement: Codable {
        public let name: String?
        public let purpose: String?
        public let rule: PresentationDefinition.Rule
        public let count: Int?
        public let min: Int?
        public let max: Int?
        public let fromNested: [SubmissionRequirement]
    }
}

/// Container for holding an array of `SubmissionRequirement`, typically used for defining and storing multiple requirements.
public struct SubmissionRequirementsContainer: Codable {
    public let submissionRequirements: [SubmissionRequirement]
}
