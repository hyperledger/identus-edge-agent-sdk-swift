import Domain
import Foundation

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
            fatalError("This should never happen since the function that returns random mnemonics nerver returns invalid mnemonics")
        }
        return (words, seed)
    }
    
    public func createKeyPair(seed: Seed, index: Int) -> KeyPair {
        CreateKeyPairOperation(
            logger: ApolloImpl.logger,
            seed: seed,
            keyPath: .init(index: index)
        ).compute()
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
}
