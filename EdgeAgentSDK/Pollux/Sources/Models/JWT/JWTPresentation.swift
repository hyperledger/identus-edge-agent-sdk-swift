import Core
import Domain
import Foundation
import JSONWebAlgorithms
import JSONWebKey
import JSONWebSignature
import JSONWebToken
import Sextant

struct VerifiablePresentationPayload: JWTRegisteredFieldsClaims {
    
    struct VerifiablePresentation: Codable {
        enum CodingKeys: String, CodingKey {
            case context = "@context"
            case type = "@type"
            case verifiableCredential
        }

        let context: Set<String>
        let type: Set<String>
        let verifiableCredential: [String]
    }

    let iss: String?
    let sub: String?
    let aud: [String]?
    let exp: Date?
    let nbf: Date?
    let iat: Date?
    let jti: String?
    let nonce: String
    let vp: [VerifiablePresentation]
    
    func validateExtraClaims() throws {}
}

struct JWTPresentation {
    
    func createPresentation(
        credential: JWTCredential,
        request: Message,
        options: [CredentialOperationsOptions]
    ) throws -> String {
        guard
            let subjectDIDOption = options.first(where: {
                if case .subjectDID = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.subjectDID(did) = subjectDIDOption
        else {
            throw PolluxError.invalidPrismDID
        }
        
        guard
            let exportableKeyOption = options.first(where: {
                if case .exportableKey = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.exportableKey(exportableKey) = exportableKeyOption
        else {
            throw PolluxError.requiresExportableKeyForOperation(operation: "Create Presentation JWT Credential")
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
                did: did,
                exportableKey: exportableKey
            )
        default:
            let payload = try vcPresentation(
                credential: credential,
                request: requestData,
                did: did
            )

            return try vcPresentationJWTString(
                payload: payload,
                exportableKey: exportableKey
            )
        }
    }

    private func presentation(
        credential: JWTCredential,
        request: Data,
        did: DID,
        exportableKey: ExportableKey
    ) throws -> String {
        let presentationRequest = try JSONDecoder.didComm().decode(PresentationExchangeRequest.self, from: request)

        guard 
            let jwtFormat = presentationRequest.presentationDefinition.format?.jwt,
            try jwtFormat.supportedTypes.contains(where: { try $0 == credential.getAlg() })
        else {
            throw PolluxError.credentialIsNotOfPresentationDefinitionRequiredAlgorithm
        }

        let credentialSubject = try JSONEncoder().encode(credential.jwtVerifiableCredential)

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
                format: "jwt",
                pathNested: .init(
                    id: $0.id,
                    path: "$.vp.verifiableCredential[0]",
                    format: "jwt"
                )
            )
        }

        let presentationSubmission = PresentationSubmission(
            definitionId: presentationRequest.presentationDefinition.id,
            descriptorMap: presentationDefinitions
        )

        let payload = try vcPresentation(
            credential: credential,
            request: request,
            did: did
        )

        let jwtString = try vcPresentationJWTString(
            payload: payload,
            exportableKey: exportableKey
        )

        let container = PresentationContainer(
            presentationSubmission: presentationSubmission,
            verifiableCredential: [AnyCodable(stringLiteral: jwtString)]
        )

        return try JSONEncoder.didComm().encode(container).tryToString()
    }

    private func vcPresentation(
        credential: JWTCredential,
        request: Data,
        did: DID
    ) throws -> ClaimsProofPresentationJWT {
        let jsonObject = try JSONSerialization.jsonObject(with: request)
        guard
            let domain = findValue(forKey: "domain", in: jsonObject),
            let challenge = findValue(forKey: "challenge", in: jsonObject)
        else { throw PolluxError.offerDoesntProvideEnoughInformation }

        return ClaimsProofPresentationJWT(
            iss: did.string,
            sub: nil,
            aud: [domain],
            exp: nil,
            nbf: nil,
            iat: nil,
            jti: nil,
            nonce: challenge,
            vp: .init(
                context: .init(["https://www.w3.org/2018/presentations/v1"]),
                type: .init(["VerifiablePresentation"]),
                verifiableCredential: [credential.jwtString]
            )
        )
    }

    private func vcPresentationJWTString(
        payload: ClaimsProofPresentationJWT,
        exportableKey: ExportableKey
    ) throws -> String {
        let keyJWK = exportableKey.jwk

        ES256KSigner.invertedBytesR_S = true

        let jwt = try JWT.signed(
            payload: payload,
            protectedHeader: DefaultJWSHeaderImpl(algorithm: .ES256K),
            key: JSONWebKey.JWK(
                keyType: .init(rawValue: keyJWK.kty)!,
                keyID: keyJWK.kid,
                x: keyJWK.x.flatMap { Data(fromBase64URL: $0) },
                y: keyJWK.y.flatMap { Data(fromBase64URL: $0) },
                d: keyJWK.d.flatMap { Data(fromBase64URL: $0) }
            )
        )

        ES256KSigner.invertedBytesR_S = false

        return jwt.jwtString
    }
}

struct ClaimsProofPresentationJWT: JWTRegisteredFieldsClaims, Codable {
    struct VerifiablePresentation: Codable {
        enum CodingKeys: String, CodingKey {
            case context = "@context"
            case type = "type"
            case verifiableCredential
        }

        let context: Set<String>
        let type: Set<String>
        let verifiableCredential: [String]
    }

    let iss: String?
    let sub: String?
    let aud: [String]?
    let exp: Date?
    let nbf: Date?
    let iat: Date?
    let jti: String?
    let nonce: String
    let vp: VerifiablePresentation
    
    func validateExtraClaims() throws {}
}

private func extractRS(from signature: Data) -> (r: Data, s: Data) {
    let rIndex = signature.startIndex
    let sIndex = signature.index(rIndex, offsetBy: 32)
    let r = signature[rIndex..<sIndex]
    let s = signature[sIndex..<signature.endIndex]
    return (r, s)
}
