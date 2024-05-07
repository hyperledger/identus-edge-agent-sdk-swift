import Core
import Foundation

/// Represents a container that holds the data for a presentation submission and the associated verifiable credentials.
public struct PresentationContainer: Codable {
    /// An optional instance of `PresentationSubmission` which includes the submission details according to a presentation definition.
    public let presentationSubmission: PresentationSubmission?

    /// An optional array of verifiable credentials. These are typically dynamic and may include different types of credentials, encoded using `AnyCodable` to handle varying schema.
    public let verifiableCredential: [AnyCodable]?

    /// Initializes a new `PresentationContainer` with a submission and associated credentials.
    /// - Parameters:
    ///   - presentationSubmission: An optional presentation submission detailing how credentials meet the requested criteria.
    ///   - verifiableCredential: An optional array of dynamically typed verifiable credentials.
    public init(presentationSubmission: PresentationSubmission? = nil, verifiableCredential: [AnyCodable]? = nil) {
        self.presentationSubmission = presentationSubmission
        self.verifiableCredential = verifiableCredential
    }
}
