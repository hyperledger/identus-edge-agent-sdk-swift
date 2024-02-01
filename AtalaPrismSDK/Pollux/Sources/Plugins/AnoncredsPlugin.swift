import Domain
import Foundation

public struct AnoncredsPlugin: PolluxPlugin {
    public let name = "anoncreds"
    public let supportedFormats = [String]()

    public init() {}

    public func isFormatSupported(_ format: String) -> Bool {
        supportedFormats.contains(format)
    }
    
    public func parseCredential(
        crendetialPayload: Data,
        parameters: [Domain.CredentialOperationsParameters]
    ) throws -> Domain.Credential {
        AnoncredsCredentialStack( // Mocked
            schema: nil,
            definition: .init(
                issuerId: nil,
                schemaId: "",
                type: "",
                tag: "",
                value: .init(primary: .init(n: "", s: "", r: [:], rctxt: "", z: ""))
            ),
            credential: .init(
                schemaId: "",
                credentialDefinitionId: "",
                values: [:],
                signature: .init(
                    primaryCredential: .init(m2: "", a: "", e: "", v: ""),
                    revocationCredential: nil),
                signatureCorrectnessProof: .init(se: "", c: ""),
                revocationRegistryId: nil,
                revocationRegistry: nil,
                witness: nil
            )
        )
    }
    
    public func processRequest(
        offerPayload: Data,
        parameters: [Domain.CredentialOperationsParameters]
    ) throws -> Data {
        Data()
    }
}
