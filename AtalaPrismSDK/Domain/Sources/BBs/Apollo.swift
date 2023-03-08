import Foundation

/// The Apollo protocol defines the set of cryptographic operations that are used in the Atala PRISM architecture.
public protocol Apollo {
    /// createRandomMnemonics creates a random set of mnemonic phrases that can be used as a seed for generating a private key.
    ///
    /// - Returns: An array of mnemonic phrases
    func createRandomMnemonics() -> [String]

    /// createSeed takes in a set of mnemonics and a passphrase, and returns a seed object used to generate a private key.
    /// This function may throw an error if the mnemonics or passphrase are invalid.
    ///
    /// - Parameters:
    ///   - mnemonics: An array of mnemonic phrases
    ///   - passphrase: A passphrase used to enhance the security of the seed
    /// - Returns: A seed object
    /// - Throws: An error if the mnemonics or passphrase are invalid
    func createSeed(mnemonics: [String], passphrase: String) throws -> Seed

    /// createRandomSeed creates a random seed and a corresponding set of mnemonic phrases.
    ///
    /// - Returns: A tuple containing an array of mnemonic phrases and a seed object
    func createRandomSeed() -> (mnemonic: [String], seed: Seed)

    /// createKeyPair creates a key pair (a private and public key) using a given seed and key curve.
    ///
    /// - Parameters:
    ///   - seed: A seed object used to generate the key pair
    ///   - curve: The key curve to use for generating the key pair
    /// - Returns: A key pair object containing a private and public key
    func createKeyPair(seed: Seed, curve: KeyCurve) throws -> KeyPair

    /// createKeyPair creates a key pair using a given seed and a specified private key. This function may throw an error if the private key is invalid.
    ///
    /// - Parameters:
    ///   - seed: A seed object used to generate the key pair
    ///   - privateKey: The private key to use for generating the key pair
    /// - Returns: A key pair object containing a private and public key
    /// - Throws: An error if the private key is invalid
    func createKeyPair(seed: Seed, privateKey: PrivateKey) throws -> KeyPair

    /// compressedPublicKey compresses a given public key into a shorter, more efficient form.
    ///
    /// - Parameter publicKey: The public key to compress
    /// - Returns: The compressed public key
    func compressedPublicKey(publicKey: PublicKey) -> CompressedPublicKey

    /// compressedPublicKey decompresses a given compressed public key into its original form.
    ///
    /// - Parameter compressedData: The compressed public key data
    /// - Returns: The decompressed public key
    func uncompressedPublicKey(compressedData: Data) -> PublicKey

    /// signMessage signs a message using a given private key, returning the signature.
    ///
    /// - Parameters:
    ///   - privateKey: The private key to use for signing the message
    ///   - message: The message to sign, in binary data form
    /// - Returns: The signature of the message
    func signMessage(privateKey: PrivateKey, message: Data) throws -> Signature

    /// signMessage signs a message using a given private key, returning the signature. This function may throw an error if the message is invalid.
    ///
    /// - Parameters:
    ///   - privateKey: The private key to use for signing the message
    ///   - message: The message to sign, in string form
    /// - Returns: The signature of the message
    /// - Throws: An error if the message is invalid
    func signMessage(privateKey: PrivateKey, message: String) throws -> Signature

    /// verifySignature verifies the authenticity of a signature using the corresponding public key, challenge, and signature. This function returns a boolean value indicating whether the signature is valid or not.
    ///
    /// - Parameters:
    ///   - publicKey: The public key associated with the signature
    ///   - challenge: The challenge used to generate the signature
    ///   - signature: The signature to verify
    /// - Returns: A boolean value indicating whether the signature is valid or not
    func verifySignature(
        publicKey: PublicKey,
        challenge: Data,
        signature: Signature
    ) throws -> Bool

    /// getPrivateJWKJson converts a private key pair into a JSON Web Key (JWK) format with a given ID. This function may throw an error if the key pair is invalid.
    ///
    /// - Parameters:
    ///   - id: The ID to use for the JWK
    ///   - keyPair: The private key pair to convert to JWK format
    /// - Returns: The private key pair in JWK format, as a string
    /// - Throws: An error if the key pair is invalid
    func getPrivateJWKJson(id: String, keyPair: KeyPair) throws -> String

    /// getPublicJWKJson converts a public key pair into a JSON Web Key (JWK) format with a given ID. This function may throw an error if the key pair is invalid.
    ///
    /// - Parameters:
    ///   - id: The ID to use for the JWK
    ///   - keyPair: The public key pair to convert to JWK format
    /// - Returns: The public key pair in JWK format, as a string
    /// - Throws: An error if the key pair is invalid
    func getPublicJWKJson(id: String, keyPair: KeyPair) throws -> String
}
