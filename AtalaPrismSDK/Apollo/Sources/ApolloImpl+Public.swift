import Domain
import Foundation

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

    /// compressedPublicKey compresses a given public key into a shorter, more efficient form.
    ///
    /// - Parameter publicKey: The public key to compress
    /// - Returns: The compressed public key
    public func compressedPublicKey(publicKey: PublicKey) throws -> PublicKey {
        guard
            publicKey.getProperty(.curve)?.lowercased() == KnownKeyCurves.secp256k1.rawValue
        else {
            throw ApolloError.invalidKeyCurve(
                invalid: publicKey.getProperty(.curve)?.lowercased() ?? "",
                valid: [KnownKeyCurves.secp256k1.rawValue]
            )
        }
        return Secp256k1PublicKey(lockedPublicKey: LockPublicKey(bytes: publicKey.raw).compressedPublicKey())
    }

//    /// compressedPublicKey decompresses a given compressed public key into its original form.
//    ///
//    /// - Parameter compressedData: The compressed public key data
//    /// - Returns: The decompressed public key
//    public func uncompressedPublicKey(compressedData: Data) -> PublicKey {
//        PublicKey(
//            curve: KeyCurve.secp256k1().name,
//            value: LockPublicKey(
//                bytes: compressedData
//            ).uncompressedPublicKey().data
//        )
//    }

    /// compressedPublicKey decompresses a given compressed public key into its original form.
    ///
    /// - Parameter compressedData: The compressed public key data
    /// - Returns: The decompressed public key
    public func uncompressedPublicKey(compressedData: Data) -> PublicKey {
        Secp256k1PublicKey(
            lockedPublicKey: LockPublicKey(bytes: compressedData).uncompressedPublicKey()
        )
    }

    public func publicKeyFrom(x: Data, y: Data) -> PublicKey {
        Secp256k1PublicKey(lockedPublicKey: LockPublicKey(x: x, y: y))
    }

    public func publicKeyPointCurve(publicKey: PublicKey) throws -> (x: Data, y: Data) {
        let points = try LockPublicKey(bytes: publicKey.raw).pointCurve()
        return (points.x.data, points.y.data)
    }

    public func createPrivateKey(parameters: [String : String]) throws -> PrivateKey {
        guard
            let keyType = parameters[KeyProperties.type.rawValue]
        else { throw ApolloError.invalidKeyType(invalid: "", valid: ValidCryptographicTypes.allCases.map(\.rawValue)) }
        switch keyType {
        case ValidCryptographicTypes.ec.rawValue:
            guard
                let curveStr = parameters[KeyProperties.curve.rawValue],
                let curve = ValidECCurves(rawValue: curveStr)
            else {
                throw ApolloError.invalidKeyCurve(
                    invalid: parameters[KeyProperties.curve.rawValue] ?? "",
                    valid: ValidECCurves.allCases.map(\.rawValue)
                )
            }
            switch curve {
            case .secp256k1:
                if
                    let keyData = parameters[KeyProperties.rawKey.rawValue].flatMap({ Data(base64Encoded: $0) }),
                    let derivationPathStr = parameters[KeyProperties.derivationPath.rawValue]
                {
                    let derivationPath = try DerivationPath(string: derivationPathStr)
                    return Secp256k1PrivateKey(lockedPrivateKey: .init(data: keyData), derivationPath: derivationPath)
                } else {
                    guard
                        let derivationPathStr = parameters[KeyProperties.derivationPath.rawValue],
                        let seedStr = parameters[KeyProperties.seed.rawValue],
                        let seed = Data(base64Encoded: seedStr)
                    else {
                        throw ApolloError.missingKeyParameters(missing: [
                            KeyProperties.derivationPath.rawValue, KeyProperties.seed.rawValue
                        ])
                    }
                    let derivationPath = try DerivationPath(string: derivationPathStr)
                    return try CreateSec256k1KeyPairOperation(
                        seed: Seed(value: seed),
                        keyPath: derivationPath
                    ).compute()
                }
            case .ed25519:
                if
                    let keyStr = parameters[KeyProperties.rawKey.rawValue],
                    let keyData = Data(base64Encoded: keyStr)
                {
                    return try CreateEd25519KeyPairOperation(logger: ApolloImpl.logger).compute(fromPrivateKey: keyData)
                }
                return CreateEd25519KeyPairOperation(logger: ApolloImpl.logger).compute()
            case .x25519:
                if
                    let keyStr = parameters[KeyProperties.rawKey.rawValue],
                    let keyData = Data(base64Encoded: keyStr)
                {
                    return try CreateX25519KeyPairOperation(logger: ApolloImpl.logger).compute(fromPrivateKey: keyData)
                }
                return CreateX25519KeyPairOperation(logger: ApolloImpl.logger).compute()
            }
        default:
            throw ApolloError.invalidKeyType(invalid: keyType, valid: ValidCryptographicTypes.allCases.map(\.rawValue))
        }
    }
    
    public func createNewLinkSecret() throws -> Key {
        try LinkSecret()
    }
}
