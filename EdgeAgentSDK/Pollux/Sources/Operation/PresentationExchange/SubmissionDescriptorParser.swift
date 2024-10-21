import Domain
import Foundation

struct SubmissionDescriptorParser {
    let parsers: [SubmissionDescriptorFormatParser]
    func parse(
        descriptor: PresentationSubmission.Descriptor,
        presentationData: Data
    ) async throws -> PresentationExchangeClaimVerifier {
        try await processPath(descriptor: descriptor, presentationData: presentationData)
    }

    func parseCredential(descriptor: PresentationSubmission.Descriptor, presentationData: Data) async throws -> Credential {
        try await processPathCredential(descriptor: descriptor, presentationData: presentationData)
    }

    private func processPathCredential(descriptor: PresentationSubmission.Descriptor, presentationData: Data) async throws -> Credential {
        guard
            let parser = parsers.first(where: { $0.format == descriptor.format })
        else {
            throw PolluxError.unsupportedSubmittedFormat(string: descriptor.format, validFormats: parsers.map(\.format))
        }

        guard let nestedDescriptor = descriptor.pathNested else {
            return try await parser.parseCredential(descriptor: descriptor, presentationData: presentationData)
        }

        let nestedPayload: Data = try await parser.parsePayload(path: descriptor.path, presentationData: presentationData)
        return try await processPathCredential(descriptor: nestedDescriptor, presentationData: nestedPayload)
    }

    private func processPath(descriptor: PresentationSubmission.Descriptor, presentationData: Data) async throws -> PresentationExchangeClaimVerifier {
        guard
            let parser = parsers.first(where: { $0.format == descriptor.format })
        else {
            throw PolluxError.unsupportedSubmittedFormat(string: descriptor.format, validFormats: parsers.map(\.format))
        }

        guard let nestedDescriptor = descriptor.pathNested else {
            return try await parser.parseClaimVerifier(descriptor: descriptor, presentationData: presentationData)
        }
        
        let nestedPayload: Data = try await parser.parsePayload(path: descriptor.path, presentationData: presentationData)
        return try await processPath(descriptor: nestedDescriptor, presentationData: nestedPayload)
    }
}
