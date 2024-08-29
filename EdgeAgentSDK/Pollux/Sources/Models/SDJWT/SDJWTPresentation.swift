import Core
import Domain
import eudi_lib_sdjwt_swift
import Foundation
import JSONWebKey

struct SDJWTPresentation {
    func createPresentation(
        credential: SDJWTCredential,
        request: Message,
        options: [CredentialOperationsOptions]
    ) throws -> String{
        guard
            let exportableKeyOption = options.first(where: {
                if case .exportableKey = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.exportableKey(exportableKey) = exportableKeyOption
        else {
            throw PolluxError.requiresExportableKeyForOperation(operation: "Create Presentation for SD-JWT Credential")
        }

        let disclosingClaims: [String]
        if
            let claims = options.first(where: {
                if case .disclosingClaims = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.disclosingClaims(claims) = claims
        {
            disclosingClaims = claims
        }
        else {
            disclosingClaims = []
        }

        guard
            let attachment = request.attachments.first,
            let requestData = request.attachments.first.flatMap({
                switch $0.data {
                case let json as AttachmentJsonData:
                    return try? JSONEncoder.didComm().encode(json.json)
                case let bas64 as AttachmentBase64:
                    return Data(fromBase64URL: bas64.base64)
                default:
                    return nil
                }
            })
        else {
            throw PolluxError.offerDoesntProvideEnoughInformation
        }

        switch attachment.format {
        case "dif/presentation-exchange/definitions@v1.0":
            return try presentation(
                credential: credential,
                request: requestData,
                disclosingClaims: disclosingClaims,
                key: exportableKey
            )
        default:
            return try vcPresentation(
                credential: credential,
                request: requestData,
                disclosingClaims: disclosingClaims,
                key: exportableKey
            )
        }
    }

    private func presentation(
        credential: SDJWTCredential,
        request: Data,
        disclosingClaims: [String],
        key: ExportableKey
    ) throws -> String {
        let presentationRequest = try JSONDecoder.didComm().decode(PresentationExchangeRequest.self, from: request)

        guard
            let jwtFormat = presentationRequest.presentationDefinition.format?.sdJwt,
            try jwtFormat.supportedTypes.contains(where: { try $0 == credential.getAlg() })
        else {
            throw PolluxError.credentialIsNotOfPresentationDefinitionRequiredAlgorithm
        }

        let credentialSubject = try credential.sdjwt.recreateClaims().recreatedClaims.rawData()

        try presentationRequest.presentationDefinition.inputDescriptors.forEach {
            try $0.constraints.fields.forEach {
                guard credentialSubject.query(values: $0.path) != nil else {
                    throw PolluxError.credentialDoesntProvideOneOrMoreInputDescriptors(path: $0.path)
                }
            }
        }
        let presentationDefinitions = presentationRequest.presentationDefinition.inputDescriptors.map {
            PresentationSubmission.Descriptor(
                id: $0.id,
                path: "$.verifiable_credential[0]",
                format: "sd_jwt"
            )
        }

        let presentationSubmission = PresentationSubmission(
            definitionId: presentationRequest.presentationDefinition.id,
            descriptorMap: presentationDefinitions
        )

        let payload = try vcPresentation(
            credential: credential,
            request: request,
            disclosingClaims: disclosingClaims,
            key: key
        )

        let container = PresentationContainer(
            presentationSubmission: presentationSubmission,
            verifiableCredential: [AnyCodable(stringLiteral: payload)]
        )

        return try JSONEncoder.didComm().encode(container).tryToString()
    }

    private func vcPresentation(
        credential: SDJWTCredential,
        request: Data,
        disclosingClaims: [String],
        key: ExportableKey
    ) throws -> String {
        let disclosures = credential.sdjwt.disclosures.filter { disclosure in
            disclosingClaims.first {
                guard
                    let decoded = try? Data(fromBase64URL: disclosure)?.tryToString()
                else { return false}
                return decoded.contains("\"\($0)\"")
            } != nil
        }

        let sdJwt = try SDJWTIssuer.presentation(
            holdersPrivateKey: key.jwk.toJoseJWK(),
            signedSDJWT: credential.sdjwt,
            disclosuresToPresent: disclosures,
            keyBindingJWT: nil
        )

        return CompactSerialiser(signedSDJWT: sdJwt).serialised
    }
}

private extension Domain.JWK {
    func toJoseJWK() throws -> JSONWebKey.JWK {
        let toJson = try JSONEncoder.jwt.encode(self)
        return try JSONDecoder.jwt.decode(JSONWebKey.JWK.self, from: toJson)
    }
}
