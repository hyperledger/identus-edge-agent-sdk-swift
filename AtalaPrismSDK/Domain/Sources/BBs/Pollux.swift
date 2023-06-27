import Foundation

/// Options that can be passed into various operations.
public enum CredentialOperationsOptions {
    case schema(json: Data)  // The JSON schema.
    case link_secret(id: String, secret: String)  // A secret link.
    case subjectDID(DID)  // The decentralized identifier of the subject.
    case entropy(String)  // Entropy for any randomization operation.
    case signableKey(SignableKey)  // A key that can be used for signing.
    case exportableKey(ExportableKey)  // A key that can be exported.
    case custom(key: String, data: Data)  // Any custom data.
}

/// The Pollux protocol defines a set of operations that are used in the Atala PRISM architecture.
public protocol Pollux {
    /// Parses an encoded item and returns an object representing the parsed item.
    /// - Parameter data: The encoded item to parse.
    /// - Throws: An error if the item cannot be parsed or decoded.
    /// - Returns: An object representing the parsed item.
    func parseCredential(data: Data) throws -> Credential

    /// Restores a previously stored item using the provided restoration identifier and data.
    /// - Parameters:
    ///   - restorationIdentifier: The identifier to use when restoring the item.
    ///   - credentialData: The data representing the stored item.
    /// - Throws: An error if the item cannot be restored.
    /// - Returns: An object representing the restored item.
    func restoreCredential(restorationIdentifier: String, credentialData: Data) throws -> Credential

    /// Processes a request based on a provided offer message and options.
    /// - Parameters:
    ///   - offerMessage: The offer message that contains the details of the request.
    ///   - options: The options to use when processing the request.
    /// - Throws: An error if the request cannot be processed.
    /// - Returns: A string representing the result of the request process.
    func processCredentialRequest(
        offerMessage: Message,
        options: [CredentialOperationsOptions]
    ) throws -> String
}

public extension Pollux {
    /// Restores a previously stored item using a `StorableCredential` instance.
    /// - Parameter storedCredential: The `StorableCredential` instance representing the stored item.
    /// - Throws: An error if the item cannot be restored.
    /// - Returns: An object representing the restored item.
    func restoreCredential(storedCredential: StorableCredential) throws -> Credential {
        try restoreCredential(
            restorationIdentifier: storedCredential.recoveryId,
            credentialData: storedCredential.credentialData
        )
    }
}
