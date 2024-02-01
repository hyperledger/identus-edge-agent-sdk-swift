import Foundation

/// Options that can be passed into various operations.
public enum CredentialOperationsParameters {
    case schema(id: String, json: String?)  // The JSON schema.
    case credentialDefinition(id: String, json: String?) // The JSON Credential Definition
    case linkSecret(id: String?, secret: String)  // A secret link.
    case subjectDID(DID)  // The decentralized identifier of the subject.
    case entropy(String)  // Entropy for any randomization operation.
    case signableKey(SignableKey)  // A key that can be used for signing.
    case exportableKey(ExportableKey)  // A key that can be exported.
    case zkpPresentationParams(attributes: [String: Bool], predicates: [String]) // Anoncreds zero-knowledge proof presentation parameters
    case custom(key: String, data: Data)  // Any custom data.
}

public protocol PolluxPlugin {
    var name: String { get }
    var supportedFormats: [String] { get }

    func isFormatSupported(_ format: String) -> Bool
    func parseCredential(crendetialPayload: Data, parameters: [CredentialOperationsParameters]) throws -> Credential
    func processRequest(offerPayload: Data, parameters: [CredentialOperationsParameters]) throws -> Data
}
