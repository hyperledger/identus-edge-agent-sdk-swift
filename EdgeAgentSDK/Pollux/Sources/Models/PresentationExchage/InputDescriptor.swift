import Foundation

/// Represents a descriptor for input validation, typically used in a credential presentation request to specify the requirements for presented credentials.
public struct InputDescriptor: Codable {
    /// Enumerates the level of importance of the input, such as required or preferred.
    public enum Predicate: String, Codable {
        case required
        case preferred
    }

    /// Enumerates the policy on how to handle certain credential fields, such as whether they are required, allowed, or disallowed.
    public enum Directive: String, Codable {
        case required
        case allowed
        case disallowed
    }

    /// Represents status directives that define conditions under which a credential must be considered valid.
    public struct StatusDirective: Codable {
        /// The directive applied to the status, e.g., required, allowed, or disallowed.
        public let directive: Directive
        /// Types of statuses that are applicable under this directive.
        public let type: [String]
    }

    /// Represents fields within the input descriptor that define specific requirements for credential data fields.
    public struct Field: Codable {
        /// Represents filters to apply to a credential's field.
        public struct Filter: Codable {
            /// The data type of the credential field.
            public let type: String
            /// The specific format that the data type should adhere to.
            public let format: String?
            /// A constant value that the credential field must match.
            public let const: String?
            /// A pattern that the credential field's value must match.
            public let pattern: String?
        }

        /// Identifier for the field, uniquely generated or predefined.
        public var id: String?
        /// Indicates whether the field is optional.
        public var optional: Bool?
        /// JSON path to the field in the credential.
        public var path: [String]
        /// Describes the purpose of collecting the data.
        public var purpose: String?
        /// Indicates intent to retain the data beyond the current transaction.
        public var intentToRetain: Bool?
        /// The name of the field, typically used for display or identification purposes.
        public var name: String?
        /// Filters that define constraints on the field's data.
        public var filter: Filter?
        /// The predicate defining the importance level of the field.
        public var predicate: Predicate?
    }

    /// Represents constraints that apply to the collection of fields in the input descriptor.
    public struct Constraint: Codable {
        /// Directive that specifies whether to limit disclosure of certain fields.
        public let limitDisclosure: Directive?
        /// Status directives that apply to the credential.
        public let statuses: Statuses?
        /// Fields that must meet the criteria defined within this constraint.
        public let fields: [Field]
        /// Predicate that specifies whether the subject of the credential must also be the issuer.
        public let subjectIsIssuer: Predicate?
        /// Directives defining whether the holder of the credential must also be the subject.
        public let isHolder: [HolderDirective]?
        /// Directives specifying requirements for credentials involving multiple subjects.
        public let sameSubject: [HolderDirective]?

        /// Initializes a new `Constraint` instance with the specified parameters.
        ///
        /// - Parameters:
        ///   - limitDisclosure: Specifies whether there are constraints on the disclosure of attributes.
        ///   - statuses: Represents the statuses directive containing statuses like active, suspended, and revoked.
        ///   - fields: An array of `Field` objects defining the constraints for each field in the credential.
        ///   - subjectIsIssuer: Indicates whether the subject of the credential is also the issuer.
        ///   - isHolder: A list of directives defining constraints for holders of the credential.
        ///   - sameSubject: A list of directives defining constraints for entities with the same subject.
        init(
            limitDisclosure: Directive? = nil,
            statuses: Statuses? = nil,
            fields: [Field],
            subjectIsIssuer: Predicate? = nil,
            isHolder: [HolderDirective]? = nil,
            sameSubject: [HolderDirective]? = nil
        ) {
            self.limitDisclosure = limitDisclosure
            self.statuses = statuses
            self.fields = fields
            self.subjectIsIssuer = subjectIsIssuer
            self.isHolder = isHolder
            self.sameSubject = sameSubject
        }
    }

    /// Represents status directives specifically for active, suspended, and revoked statuses of a credential.
    public struct Statuses: Codable {
        /// Directive for active credentials.
        public let active: StatusDirective
        /// Directive for suspended credentials.
        public let suspended: StatusDirective
        /// Directive for revoked credentials.
        public let revoked: StatusDirective
    }

    /// Represents directives that specify how fields related to the holder of the credential should be treated.
    public struct HolderDirective: Codable {
        /// Identifiers of fields affected by the directive.
        public let fieldId: [String]
        /// The directive to apply to the holder-related fields.
        public let directive: Directive
    }

    /// Unique identifier for the descriptor.
    public let id: String
    /// Optional name of the descriptor.
    public let name: String?
    /// Optional purpose of collecting and presenting the data.
    public let purpose: String?
    /// Optional grouping for the descriptor to categorize it within the presentation request.
    public let group: [String]?
    /// Constraints that specify requirements for the presentation of the credentials.
    public let constraints: Constraint

    /// Initializes a new `InputDescriptor` with specified properties.
    /// - Parameters:
    ///   - id: Identifier for the descriptor.
    ///   - name: Optional name for the descriptor.
    ///   - purpose: Optional purpose for data collection.
    ///   - group: Optional groups to categorize the descriptor.
    ///   - constraints: Constraints applied to the fields within the descriptor.
    public init(
        id: String = UUID().uuidString,
        name: String? = nil,
        purpose: String? = nil,
        group: [String]? = nil,
        constraints: Constraint
    ) {
        self.id = id
        self.name = name
        self.purpose = purpose
        self.group = group
        self.constraints = constraints
    }
}
