import Domain
import Foundation
import JSONSchema

struct VerifyPresentationSubmissionJWT {
    static func verifyPresentationSubmissionClaims(
        request: PresentationDefinition,
        credentials: [Data]
    ) throws {
        let requiredInputDescriptors = presentationClaimsRequirements(request: request)
        try validateCredentialPresentationClaims(inputDescriptors: requiredInputDescriptors, jsonData: credentials)
    }

    static func validateCredentialPresentationClaims(inputDescriptors: [InputDescriptor], jsonData: [Data]) throws {
        var inputErrors = [Error]()
        inputDescriptors.forEach { input in
            var errors = [Error]()
            var descriptorValid = false
            jsonData.forEach {
                guard !descriptorValid else { return }
                do {
                    try validateCredentialPresentationClaims(inputDescriptor: input, jsonData: $0)
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

    static private func validateCredentialPresentationClaims(inputDescriptor: InputDescriptor, jsonData: Data) throws {
        struct FieldValidation {
            let valid: Bool
            let error: Error
        }

        let requiredFields = inputDescriptor
            .constraints
            .fields
            .filter { $0.optional == nil || $0.optional == false }

        let fieldValidations = try requiredFields.map { field in
            var validatedField = false
            var errors = [Error]()

             try field.path.forEach {
                 guard !validatedField else { return }
                 let filterJson = try field.filter.map { try JSONEncoder().encode($0) }

                 do {
                     try queryAndValidatePath($0, filter: filterJson?.tryToString(), jsonData: jsonData)
                     validatedField = true
                 } catch {
                     errors.append(error)
                 }
            }

            return FieldValidation(
                valid: validatedField,
                error: PolluxError.cannotVerifyInputField(
                    name: field.name,
                    paths: field.path,
                    internalErrors: errors)
            )
        }

        guard fieldValidations.allSatisfy(\.valid) else {
            let errors = fieldValidations.filter { !$0.valid }.map(\.error)
            throw PolluxError.cannotVerifyInput(name: inputDescriptor.name, purpose: inputDescriptor.purpose, fieldErrors: errors)
        }
    }

    static private func queryAndValidatePath(_ path: String, filter: String?, jsonData: Data) throws {
        let query = jsonData.query(values: path)?.first

        guard query != nil else { throw PolluxError.inputPathNotFound(path: path) }
        guard let filter else { return }

        let jsonFilter = try JSONSerialization.jsonObject(with: filter.tryToData()) as? [String: Any]
        switch try JSONSchema.validate(["value": query], schema: [
            "type": "object",
            "properties": [
                "value": jsonFilter
            ]
        ]) {
        case .valid:
            return
        case .invalid(let errors):
            throw PolluxError.inputFilterErrors(descriptions: errors.map(\.description))
        }
    }

    static private func presentationClaimsRequirements(request: PresentationDefinition) -> [InputDescriptor] {
        return request.inputDescriptors.filter { $0.constraints.fields.contains { $0.optional == nil || $0.optional == false } }
    }
}
