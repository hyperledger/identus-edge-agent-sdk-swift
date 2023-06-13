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

    func publicKeyFrom(x: Data, y: Data) -> PublicKey

    func createPrivateKey(parameters: [String: String]) throws -> PrivateKey

    /// compressedPublicKey compresses a given public key into a shorter, more efficient form.
    ///
    /// - Parameter publicKey: The public key to compress
    /// - Returns: The compressed public key
    func compressedPublicKey(publicKey: PublicKey) throws -> PublicKey

//    /// compressedPublicKey decompresses a given compressed public key into its original form.
//    ///
//    /// - Parameter compressedData: The compressed public key data
//    /// - Returns: The decompressed public key
//    func uncompressedPublicKey(compressedData: Data) -> PublicKey

    /// compressedPublicKey decompresses a given compressed public key into its original form.
    ///
    /// - Parameter compressedData: The compressed public key data
    /// - Returns: The decompressed public key
    func uncompressedPublicKey(compressedData: Data) -> PublicKey
}
