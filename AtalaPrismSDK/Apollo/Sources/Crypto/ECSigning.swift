import CryptoKit
import Foundation
import secp256k1

struct ECSigning {
    let data: Data
    let privateKey: Data

    func signMessage() throws -> Data {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        defer { secp256k1_context_destroy(ctx) }

        let signature = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signature.deallocate() }
        let status = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            privateKey.withUnsafeBytes {
                secp256k1_ecdsa_sign(
                    ctx,
                    signature,
                    ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                    $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                    nil,
                    nil
                )
            }
        }
        guard status == 1 else { throw CryptoError.signFailed }

        let normalizedsig = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { normalizedsig.deallocate() }
        secp256k1_ecdsa_signature_normalize(ctx, normalizedsig, signature)

        var length: size_t = 128
        var der = Data(count: length)
        guard der.withUnsafeMutableBytes({
            return secp256k1_ecdsa_signature_serialize_der(
                ctx,
                $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                &length,
                normalizedsig
            ) }) == 1 else { throw CryptoError.noEnoughSpace }
        der.count = length

        return der
    }

    public enum CryptoError: Error {
        case signFailed
        case noEnoughSpace
    }
}
