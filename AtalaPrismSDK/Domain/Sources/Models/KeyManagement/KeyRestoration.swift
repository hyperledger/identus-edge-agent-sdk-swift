import Foundation

/// The KeyRestoration protocol defines methods for verifying and restoring cryptographic keys from raw data.
public protocol KeyRestoration {
    /// Determines if the given data corresponds to a private key.
    /// - Parameters:
    /// - identifier: An optional string used to identify the key.
    /// - data: The raw data potentially representing the key.
    /// - Throws: If the verification process fails, this method throws an error.
    /// - Returns: A boolean value indicating whether the data represents a private key (true) or not (false).
    func isPrivateKeyData(identifier: String, data: Data) throws -> Bool

    /// Determines if the given data corresponds to a public key.
    /// - Parameters:
    ///   - identifier: An optional string used to identify the key.
    ///   - data: The raw data potentially representing the key.
    /// - Throws: If the verification process fails, this method throws an error.
    /// - Returns: A boolean value indicating whether the data represents a public key (true) or not (false).
    func isPublicKeyData(identifier: String, data: Data) throws -> Bool

    /// Restores a private key from the given data.
    /// - Parameters:
    ///   - identifier: An optional string used to identify the key.
    ///   - data: The raw data representing the key.
    /// - Throws: If the restoration process fails, this method throws an error.
    /// - Returns: The restored `PrivateKey` instance.
    func restorePrivateKey(identifier: String?, data: Data) async throws -> PrivateKey

    /// Restores a public key from the given data.
    /// - Parameters:
    ///   - identifier: An optional string used to identify the key.
    ///   - data: The raw data representing the key.
    /// - Throws: If the restoration process fails, this method throws an error.
    /// - Returns: The restored `PublicKey` instance.
    func restorePublicKey(identifier: String?, data: Data) async throws -> PublicKey
}

/// Extension of the KeyRestoration protocol to provide additional restoration methods.
public extension KeyRestoration {
    /// Restores a private key from the given data, without requiring an identifier.
    /// - Parameter data: The raw data representing the key.
    /// - Throws: If the restoration process fails, this method throws an error.
    /// - Returns: The restored PrivateKey instance.
    func restorePrivateKey(data: Data) async throws -> PrivateKey {
        try await restorePrivateKey(identifier: nil, data: data)
    }
    
    /// Restores a public key from the given data, without requiring an identifier.
    /// - Parameter data: The raw data representing the key.
    /// - Throws: If the restoration process fails, this method throws an error.
    /// - Returns: The restored `PublicKey` instance.
    func restorePublicKey(data: Data) async throws -> PublicKey {
        try await restorePublicKey(identifier: nil, data: data)
    }
}
