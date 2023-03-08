//
//  File.swift
//  
//
//  Created by Goncalo Frade IOHK on 07/03/2023.
//

import Foundation
import secp256k1

struct ECVerify {
    let signature: Data
    let message: Data
    let publicKey: Data


    func verifySignature() throws -> Bool {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY))!
        defer { secp256k1_context_destroy(ctx) }

        let signaturePointer = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signaturePointer.deallocate() }
        guard signature.withUnsafeBytes({
            secp256k1_ecdsa_signature_parse_der(
                ctx,
                signaturePointer,
                $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                signature.count
            )
        }) == 1 else {
            throw CryptoError.signatureParseFailed
        }

        let pubkeyPointer = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        defer { pubkeyPointer.deallocate() }
        guard publicKey.withUnsafeBytes({
            secp256k1_ec_pubkey_parse(
                ctx,
                pubkeyPointer,
                $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                publicKey.count
            ) }) == 1 else {
            throw CryptoError.publicKeyParseFailed
        }

        guard message.withUnsafeBytes ({
            secp256k1_ecdsa_verify(
                ctx,
                signaturePointer,
                $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                pubkeyPointer) }) == 1 else {
            return false
        }

        return true
    }

    public enum CryptoError: Error {
        case signatureParseFailed
        case publicKeyParseFailed
    }
}
