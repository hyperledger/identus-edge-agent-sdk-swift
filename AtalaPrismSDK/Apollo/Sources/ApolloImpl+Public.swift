import Domain
import Foundation
import SwiftJWT

extension ApolloImpl: Apollo {
    /// createRandomMnemonics creates a random set of mnemonic phrases that can be used as a seed for generating a private key.
    ///
    /// - Returns: An array of mnemonic phrases
    public func createRandomMnemonics() -> [String] {
        RandomMnemonicsOperation(logger: ApolloImpl.logger).compute()
    }

    /// createSeed takes in a set of mnemonics and a passphrase, and returns a seed object used to generate a private key.
    /// This function may throw an error if the mnemonics or passphrase are invalid.
    ///
    /// - Parameters:
    ///   - mnemonics: An array of mnemonic phrases
    ///   - passphrase: A passphrase used to enhance the security of the seed
    /// - Returns: A seed object
    /// - Throws: An error if the mnemonics or passphrase are invalid
    public func createSeed(mnemonics: [String], passphrase: String) throws -> Seed {
        try CreateSeedOperation(logger: ApolloImpl.logger, words: mnemonics, passphrase: passphrase).compute()
    }

    /// createRandomSeed creates a random seed and a corresponding set of mnemonic phrases.
    ///
    /// - Returns: A tuple containing an array of mnemonic phrases and a seed object
    public func createRandomSeed() -> (mnemonic: [String], seed: Seed) {
        let words = createRandomMnemonics()
        guard let seed = try? createSeed(mnemonics: words, passphrase: "") else {
            fatalError("""
This should never happen since the function that
returns random mnemonics nerver returns invalid mnemonics
""")
        }
        return (words, seed)
    }

    /// createKeyPair creates a key pair (a private and public key) using a given seed and key curve.
    ///
    /// - Parameters:
    ///   - seed: A seed object used to generate the key pair
    ///   - curve: The key curve to use for generating the key pair
    /// - Returns: A key pair object containing a private and public key
    public func createKeyPair(seed: Seed, curve: KeyCurve) throws -> KeyPair {
        switch curve {
        case .x25519:
            return CreateX25519KeyPairOperation(logger: ApolloImpl.logger)
                .compute()
        case .ed25519:
            return CreateEd25519KeyPairOperation(logger: ApolloImpl.logger)
                .compute()
        case let .secp256k1(index):
            return try CreateSec256k1KeyPairOperation(
                logger: ApolloImpl.logger,
                seed: seed,
                keyPath: .init(index: index)
            ).compute()
        }
    }

    /// createKeyPair creates a key pair using a given seed and a specified private key. This function may throw an error if the private key is invalid.
    ///
    /// - Parameters:
    ///   - seed: A seed object used to generate the key pair
    ///   - privateKey: The private key to use for generating the key pair
    /// - Returns: A key pair object containing a private and public key
    /// - Throws: An error if the private key is invalid
    public func createKeyPair(seed: Seed, privateKey: PrivateKey) throws -> KeyPair {
        switch privateKey.curve {
        case .secp256k1:
            return try createKeyPair(seed: seed, curve: privateKey.curve)
        case .x25519:
            return try CreateX25519KeyPairOperation(logger: ApolloImpl.logger)
                .compute(fromPrivateKey: privateKey)
        case .ed25519:
            return try CreateEd25519KeyPairOperation(logger: ApolloImpl.logger)
                .compute(fromPrivateKey: privateKey)
        }
    }

    /// compressedPublicKey compresses a given public key into a shorter, more efficient form.
    ///
    /// - Parameter publicKey: The public key to compress
    /// - Returns: The compressed public key
    public func compressedPublicKey(publicKey: PublicKey) -> CompressedPublicKey {
        CompressedPublicKey(
            uncompressed: publicKey,
            value: LockPublicKey(
                bytes: publicKey.value
            ).compressedPublicKey().data
        )
    }

    /// compressedPublicKey decompresses a given compressed public key into its original form.
    ///
    /// - Parameter compressedData: The compressed public key data
    /// - Returns: The decompressed public key
    public func uncompressedPublicKey(compressedData: Data) -> PublicKey {
        PublicKey(
            curve: KeyCurve.secp256k1().name,
            value: LockPublicKey(
                bytes: compressedData
            ).uncompressedPublicKey().data
        )
    }

    public func publicKeyFrom(x: Data, y: Data) -> PublicKey {
        PublicKey(
            curve: KeyCurve.secp256k1().name,
            value: LockPublicKey(x: x, y: y).data
        )
    }

    public func publicKeyPointCurve(publicKey: PublicKey) throws -> (x: Data, y: Data) {
        let points = try LockPublicKey(bytes: publicKey.value).pointCurve()
        return (points.x.data, points.y.data)
    }

    /// signMessage signs a message using a given private key, returning the signature.
    ///
    /// - Parameters:
    ///   - privateKey: The private key to use for signing the message
    ///   - message: The message to sign, in binary data form
    /// - Returns: The signature of the message
    public func signMessage(privateKey: PrivateKey, message: Data) throws -> Signature {
        return try SignMessageOperation(
            logger: ApolloImpl.logger,
            privateKey: privateKey,
            message: message
        ).compute()
    }

    /// signMessage signs a message using a given private key, returning the signature. This function may throw an error if the message is invalid.
    ///
    /// - Parameters:
    ///   - privateKey: The private key to use for signing the message
    ///   - message: The message to sign, in string form
    /// - Returns: The signature of the message
    /// - Throws: An error if the message is invalid
    public func signMessage(privateKey: PrivateKey, message: String) throws -> Signature {
        guard let data = message.data(using: .utf8) else { throw ApolloError.couldNotParseMessageString }
        return try signMessage(privateKey: privateKey, message: data)
    }

    /// verifySignature verifies the authenticity of a signature using the corresponding public key, challenge, and signature. This function returns a boolean value indicating whether the signature is valid or not.
    ///
    /// - Parameters:
    ///   - publicKey: The public key associated with the signature
    ///   - challenge: The challenge used to generate the signature
    ///   - signature: The signature to verify
    /// - Returns: A boolean value indicating whether the signature is valid or not
    public func verifySignature(
        publicKey: PublicKey,
        challenge: Data,
        signature: Signature
    ) throws -> Bool {
        return try VerifySignatureOperation(
            logger: ApolloImpl.logger,
            publicKey: publicKey,
            challenge: challenge,
            signature: signature
        ).compute()
    }

    /// getPrivateJWKJson converts a private key pair into a JSON Web Key (JWK) format with a given ID. This function may throw an error if the key pair is invalid.
    ///
    /// - Parameters:
    ///   - id: The ID to use for the JWK
    ///   - keyPair: The private key pair to convert to JWK format
    /// - Returns: The private key pair in JWK format, as a string
    /// - Throws: An error if the key pair is invalid
    public func getPrivateJWKJson(id: String, keyPair: KeyPair) throws -> String {
        guard
            let jsonString = try OctetKeyPair(id: id, from: keyPair).privateJson
        else { throw ApolloError.invalidJWKError }
        return jsonString
    }

    /// getPublicJWKJson converts a public key pair into a JSON Web Key (JWK) format with a given ID. This function may throw an error if the key pair is invalid.
    ///
    /// - Parameters:
    ///   - id: The ID to use for the JWK
    ///   - keyPair: The public key pair to convert to JWK format
    /// - Returns: The public key pair in JWK format, as a string
    /// - Throws: An error if the key pair is invalid
    public func getPublicJWKJson(id: String, keyPair: KeyPair) throws -> String {
        guard
            let jsonString = try OctetKeyPair(id: id, from: keyPair).privateJson
        else { throw ApolloError.invalidJWKError }
        return jsonString
    }

    public func verifyJWT(jwk: String, publicKey: PublicKey) throws -> String {
        switch publicKey.curve {
        case "secp256k1":
            let verifier = JWTVerifier.es256(publicKey: publicKey.value)
            let decoder = JWTDecoder(jwtVerifier: verifier)
            return jwk
        default:
            let verifier = JWTVerifier.none
            let decoder = JWTDecoder(jwtVerifier: verifier)
            return jwk
        }
    }

    public func keyDataToPEMString(_ keyData: PrivateKey) -> String? {
        let keyBase64 = keyData.value.base64EncodedString(options: .lineLength64Characters)
        let pemString = """
        -----BEGIN PRIVATE KEY-----
        \(keyBase64)
        -----END PRIVATE KEY-----
        """
        return pemString
    }

    public func keyDataToPEMString(_ keyData: PublicKey) -> String? {
        let keyBase64 = keyData.value.base64EncodedString(options: .lineLength64Characters)
        let pemString = """
        -----BEGIN PUBLIC KEY-----
        \(keyBase64)
        -----END PUBLIC KEY-----
        """
        return pemString
    }
}

struct MyClaims: Claims {
    let iss: String
    let sub: String
    let exp: Date
}
