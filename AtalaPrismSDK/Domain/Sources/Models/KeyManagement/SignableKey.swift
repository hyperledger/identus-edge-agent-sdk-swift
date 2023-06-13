import Foundation

/// The `SignableKey` protocol defines a cryptographic key that can be used for signing data.
public protocol SignableKey {
    /// The algorithm used by the key for signing data (e.g., "RSA", "ECDSA").
    var algorithm: String { get }

    /// Signs the given data using the key.
    /// - Parameter data: The data to be signed.
    /// - Throws: If the signing process fails, this method throws an error.
    /// - Returns: A `Signature` instance representing the signed data.
    func sign(data: Data) async throws -> Signature
}

/// The `Signature` structure represents a signature produced by a `SignableKey`.
public struct Signature {
    /// The algorithm used for signing the data.
    public let algorithm: String

    /// The specifications of the signature, represented as a dictionary of specification attributes and their corresponding values.
    public let signatureSpecifications: [String: Any]

    /// The raw data representation of the signature.
    public let raw: Data

    /// Initializes a new `Signature`.
    /// - Parameters:
    ///   - algorithm: The algorithm used for signing the data.
    ///   - signatureSpecifications: The specifications of the signature.
    ///   - raw: The raw data representation of the signature.
    public init(algorithm: String, signatureSpecifications: [String : Any], raw: Data) {
        self.algorithm = algorithm
        self.signatureSpecifications = signatureSpecifications
        self.raw = raw
    }
}

/// Extension of the `Key` protocol to provide additional functionality related to signing.
public extension Key {
    /// A boolean value indicating whether the key can be used for signing data.
    var isSignable: Bool { self is SignableKey }

    /// Returns this key as a `SignableKey`, or `nil` if the key cannot be used for signing.
    var signing: SignableKey? { self as? SignableKey }
}
