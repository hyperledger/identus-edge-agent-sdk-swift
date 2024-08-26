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
