import Domain
import Foundation

public struct JWTPlugin: PolluxPlugin {
    public let name = "jwt"
    public let supportedFormats = [String]()

    public init() {}

    public func isFormatSupported(_ format: String) -> Bool {
        supportedFormats.contains(format)
    }

    public func parseCredential(
        crendetialPayload: Data,
        parameters: [Domain.CredentialOperationsParameters]
    ) throws -> Domain.Credential {
        try JWTCredential(data: Data())
    }

    public func processRequest(
        offerPayload: Data,
        parameters: [Domain.CredentialOperationsParameters]
    ) throws -> Data {
        Data()
    }
}
