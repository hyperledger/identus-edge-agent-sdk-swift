import CryptoKit
import Foundation
import secp256k1

struct ECVerify {
    public enum CryptoError: String, Error {
        case signatureParseFailed
        case publicKeyParseFailed
    }

    let signature: Data
    let message: Data
    let publicKey: Data

    func verifySignature() throws -> Bool {
        let signature = try getSignatureFromData(signature)
        return try secp256k1
            .Signing
            .PublicKey(
                rawRepresentation: publicKey,
                format: LockPublicKey(bytes: publicKey).isCompressed ? .compressed : .uncompressed
            )
            .ecdsa
            .isValidSignature(signature, for: SHA256.hash(data: message))
    }

    private func getSignatureFromData(_ data: Data) throws -> secp256k1.Signing.ECDSASignature {
        if let derSignature = try? secp256k1.Signing.ECDSASignature(derRepresentation: data) {
            return derSignature
        } else if let rawSignature = try? secp256k1.Signing.ECDSASignature(rawRepresentation: data) {
            return rawSignature
        } else if let compactSignature = try? secp256k1.Signing.ECDSASignature(compactRepresentation: data) {
            return compactSignature
        } else {
            throw CryptoError.signatureParseFailed
        }
    }
}
