import Domain
import Foundation
import SwiftJWT

extension ApolloImpl: Apollo {
    public func createRandomMnemonics() -> [String] {
        RandomMnemonicsOperation(logger: ApolloImpl.logger).compute()
    }

    public func createSeed(mnemonics: [String], passphrase: String) throws -> Seed {
        try CreateSeedOperation(logger: ApolloImpl.logger, words: mnemonics, passphrase: passphrase).compute()
    }

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

    public func createKeyPair(seed: Seed, curve: KeyCurve) -> KeyPair {
        switch curve {
        case .x25519:
            return CreateX25519KeyPairOperation(logger: ApolloImpl.logger)
                .compute()
        case .ed25519:
            return CreateEd25519KeyPairOperation(logger: ApolloImpl.logger)
                .compute()
        case let .secp256k1(index):
            return CreateSec256k1KeyPairOperation(
                logger: ApolloImpl.logger,
                seed: seed,
                keyPath: .init(index: index)
            ).compute()
        }
    }

    public func createKeyPair(seed: Seed, privateKey: PrivateKey) throws -> KeyPair {
        switch privateKey.curve {
        case .secp256k1:
            return createKeyPair(seed: seed, curve: privateKey.curve)
        case .x25519:
            return try CreateX25519KeyPairOperation(logger: ApolloImpl.logger)
                .compute(fromPrivateKey: privateKey)
        case .ed25519:
            return try CreateEd25519KeyPairOperation(logger: ApolloImpl.logger)
                .compute(fromPrivateKey: privateKey)
        }
    }

    public func compressedPublicKey(publicKey: PublicKey) -> CompressedPublicKey {
        publicKey.compressed()
    }

    public func compressedPublicKey(compressedData: Data) -> CompressedPublicKey {
        CompressedPublicKey(compressedData: compressedData)
    }

    public func signMessage(privateKey: PrivateKey, message: Data) -> Signature {
        return SignMessageOperation(
            logger: ApolloImpl.logger,
            privateKey: privateKey,
            message: message
        ).compute()
    }

    public func signMessage(privateKey: PrivateKey, message: String) throws -> Signature {
        guard let data = message.data(using: .utf8) else { throw ApolloError.couldNotParseMessageString }
        return signMessage(privateKey: privateKey, message: data)
    }

    public func verifySignature(publicKey: PublicKey, challenge: Data, signature: Signature) -> Bool {
        return VerifySignatureOperation(
            logger: ApolloImpl.logger,
            publicKey: publicKey,
            challenge: challenge,
            signature: signature
        ).compute()
    }

    public func getPrivateJWKJson(id: String, keyPair: KeyPair) throws -> String {
        guard
            let jsonString = try OctetKeyPair(id: id, from: keyPair).privateJson
        else { throw CommonError.somethingWentWrongError }
        return jsonString
    }

    public func getPublicJWKJson(id: String, keyPair: KeyPair) throws -> String {
        guard
            let jsonString = try OctetKeyPair(id: id, from: keyPair).privateJson
        else { throw CommonError.somethingWentWrongError }
        return jsonString
    }

    public func verifyJWT(jwk: String, publicKey: PublicKey) throws -> String {
        switch publicKey.curve {
        case "secp256k1":
            let verifier = JWTVerifier.es256(publicKey: publicKey.value)
            let decoder = JWTDecoder.init(jwtVerifier: verifier)
            let jwt = try decoder.decode(JWT<MyClaims>.self, fromString: jwk)
            return jwk
        default:
            let verifier = JWTVerifier.none
            let decoder = JWTDecoder.init(jwtVerifier: verifier)
            let jwt = try decoder.decode(JWT<MyClaims>.self, fromString: jwk)
            return jwk
        }
    }
}

struct MyClaims: Claims {
    let iss: String
    let sub: String
    let exp: Date
}
