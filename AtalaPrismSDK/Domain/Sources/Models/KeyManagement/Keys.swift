import Foundation

/// The Key protocol defines a cryptographic key with essential properties.
/// Each key has a type (e.g., "RSA", "ECC"), a set of specifications, a size, and a raw data representation.
public protocol Key {

    /// The type of the key (e.g., "RSA", "ECC")
    var keyType: String { get }

    /// The specifications of the key, represented as a dictionary of specification attributes and their corresponding values.
    var keySpecifications: [String: String] { get }

    /// The size of the key, in bits.
    var size: Int { get }

    /// The raw data representation of the key.
    var raw: Data { get }
}

/// The PrivateKey protocol represents a cryptographic private key.
/// In addition to the properties of a Key, it provides a method to derive its corresponding public key.
public protocol PrivateKey: Key {

    // Derives the public key corresponding to this private key.
    /// - Returns: The corresponding PublicKey instance.
    func publicKey() -> PublicKey
}

/// The PublicKey protocol represents a cryptographic public key.
/// In addition to the properties of a Key, it provides a method to verify the signature of data using this key.
public protocol PublicKey: Key {

    /// Verifies the signature of the given data using this public key.
    /// - Parameters:
    /// - data: The data whose signature is to be verified.
    /// - signature: The signature to verify.
    /// - Throws: If the verification process fails, this method throws an error.
    /// - Returns: A boolean value indicating whether the signature is valid (true) or not (false).
    func verify(data: Data, signature: Data) async throws -> Bool
}

public extension Key {

    /// Returns the value of a specified property of the key.
    /// - Parameter spec: The property whose value should be retrieved, defined in KeyProperties.
    /// - Returns: The value of the property as a String, or nil if the property does not exist.
    func getProperty(_ spec: KeyProperties) -> String? {
        self.keySpecifications[spec.rawValue]
    }
}
