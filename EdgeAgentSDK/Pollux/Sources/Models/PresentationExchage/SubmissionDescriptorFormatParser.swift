import Domain
import Foundation

public protocol SubmissionDescriptorFormatParser {
    var format: String { get }
    func parse(path: String, presentationData: Data) async throws -> String
    func parsePayload(path: String, presentationData: Data) async throws -> Data
    func parseClaimVerifier(descriptor: PresentationSubmission.Descriptor, presentationData: Data) async throws -> PresentationExchangeClaimVerifier
    func parseCredential(descriptor: PresentationSubmission.Descriptor, presentationData: Data) async throws -> Credential
}
