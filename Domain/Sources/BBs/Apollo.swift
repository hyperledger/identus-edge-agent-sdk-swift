import Foundation

public protocol Apollo {
    func createRandomMnemonics() -> [String]
    func createSeed(mnemonics: [String]) throws -> Seed
    func createRandomSeed() -> (mnemonic: [String], seed: Seed)
    func createKeyPair(seed: Seed, index: Int) -> KeyPair
    func compressedPublicKey(publicKey: PublicKey) -> CompressedPublicKey
    func compressedPublicKey(compressedData: Data) -> CompressedPublicKey
    func signMessage(privateKey: PrivateKey, message: Data) -> Signature
    func signMessage(privateKey: PrivateKey, message: String) throws -> Signature
    func verifySignature(
        publicKey: PublicKey,
        challenge: Data,
        signature: Signature
    ) -> Bool
}
