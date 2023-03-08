//
//  BitcoinKitPrivateSwift.swift
//
//  Copyright © 2019 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
// Modified by Gonçalo Frade on 07/03/2023
//
// Changes made:
// - Moved to a file of its own
// - Removed Fingerprints and Network
// - Removed Public

import CryptoKit
import Foundation
import secp256k1

class HDKey {
    private(set) var privateKey: Data?
    private(set) var publicKey: Data
    private(set) var chainCode: Data
    private(set) var depth: UInt8
    private(set) var childIndex: UInt32

    init(privateKey: Data?, publicKey: Data, chainCode: Data, depth: UInt8, childIndex: UInt32) {
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.chainCode = chainCode
        self.depth = depth
        self.childIndex = childIndex
    }

    func derived(at childIndex: UInt32, hardened: Bool) -> HDKey? {
        var data = Data()
        if hardened {
            data.append(0)
            guard let privateKey = self.privateKey else {
                return nil
            }
            data.append(privateKey)
        } else {
            data.append(publicKey)
        }
        var childIndex = CFSwapInt32HostToBig(hardened ? (0x80000000 as UInt32) | childIndex : childIndex)
        data.append(Data(bytes: &childIndex, count: MemoryLayout<UInt32>.size))
        let hmac = HMAC<SHA512>.authenticationCode(for: data, using: .init(data: self.chainCode))
        let digest = Data(hmac)
        let derivedPrivateKey: [UInt8] = digest[0..<32].map { $0 }
        let derivedChainCode: [UInt8] = digest[32..<64].map { $0 }
        var result: Data
        if let privateKey = self.privateKey {
            guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
                return nil
            }
            defer { secp256k1_context_destroy(ctx) }
            var privateKeyBytes = privateKey.map { $0 }
            var derivedPrivateKeyBytes = derivedPrivateKey.map { $0 }
            if secp256k1_ec_seckey_tweak_add(ctx, &privateKeyBytes, &derivedPrivateKeyBytes) == 0 {
                return nil
            }
            result = Data(privateKeyBytes)
        } else {
            guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY)) else {
                return nil
            }
            defer { secp256k1_context_destroy(ctx) }
            let publicKeyBytes: [UInt8] = publicKey.map { $0 }
            var secpPubkey = secp256k1_pubkey()
            if secp256k1_ec_pubkey_parse(ctx, &secpPubkey, publicKeyBytes, publicKeyBytes.count) == 0 {
                return nil
            }
            if secp256k1_ec_pubkey_tweak_add(ctx, &secpPubkey, derivedPrivateKey) == 0 {
                return nil
            }
            var compressedPublicKeyBytes = [UInt8](repeating: 0, count: 33)
            var compressedPublicKeyBytesLen = 33
            if secp256k1_ec_pubkey_serialize(ctx, &compressedPublicKeyBytes, &compressedPublicKeyBytesLen, &secpPubkey, UInt32(SECP256K1_EC_COMPRESSED)) == 0 {
                return nil
            }
            result = Data(compressedPublicKeyBytes)
        }
        return HDKey(privateKey: result, publicKey: result, chainCode: Data(derivedChainCode), depth: self.depth + 1, childIndex: childIndex)
    }
}
