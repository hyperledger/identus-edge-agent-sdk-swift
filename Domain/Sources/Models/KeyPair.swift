import Foundation

public struct KeyPair {
    public let index: Int
    public let privateKey: PrivateKey
    public let publicKey: PublicKey
    
    public init(index: Int = 0, privateKey: PrivateKey, publicKey: PublicKey) {
        self.index = index
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}
