import Core
import Domain
import Foundation
import JSONSchema
import JSONWebAlgorithms
import JSONWebToken
import JSONWebSignature

struct VerifyPresentationSubmission {
    let castor: Castor
    let parsers: [SubmissionDescriptorFormatParser]

    func verifyPresentationSubmission(
        json: Data,
        presentationRequest: PresentationExchangeRequest
    ) async throws -> Bool {
        let presentationContainer = try JSONDecoder.didComm().decode(PresentationContainer.self, from: json)
        guard let submission = presentationContainer.presentationSubmission else {
            throw PolluxError.presentationSubmissionNotAvailable
        }
        let verifiers = try await submission.descriptorMap.asyncMap { descriptor in
            return try await SubmissionDescriptorParser(parsers: parsers)
                .parse(descriptor: descriptor, presentationData: json)
        }
        try verifyPresentationSubmissionClaims(
            request: presentationRequest.presentationDefinition,
            claimVerifiers: verifiers
        )
        return true
    }

    private func verifyPresentationSubmissionClaims(
        request: PresentationDefinition,
        claimVerifiers: [PresentationExchangeClaimVerifier]
    ) throws {
        let requiredInputDescriptors = presentationClaimsRequirements(request: request)
        try validateCredentialPresentationClaims(inputDescriptors: requiredInputDescriptors, claimVerifiers: claimVerifiers)
    }

    private func validateCredentialPresentationClaims(
        inputDescriptors: [InputDescriptor],
        claimVerifiers: [PresentationExchangeClaimVerifier]
    ) throws {
        var inputErrors = [Error]()
        inputDescriptors.forEach { input in
            var errors = [Error]()
            var descriptorValid = false
            claimVerifiers.forEach {
                guard !descriptorValid else { return }
                do {
                    try $0.verifyClaim(inputDescriptor: input)
                    descriptorValid = true
                } catch {
                    errors.append(error)
                }
            }

            if !descriptorValid {
                inputErrors.append(contentsOf: errors)
            }
        }

        guard inputErrors.isEmpty else {
            throw PolluxError.cannotVerifyPresentationInputs(errors: inputErrors)
        }
    }

    private func presentationClaimsRequirements(request: PresentationDefinition) -> [InputDescriptor] {
        return request.inputDescriptors.filter { $0.constraints.fields.contains { $0.optional == nil || $0.optional == false } }
    }
}
