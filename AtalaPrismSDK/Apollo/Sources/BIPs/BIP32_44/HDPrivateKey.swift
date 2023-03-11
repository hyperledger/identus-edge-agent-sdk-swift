//
//  DeterministicKey.swift
//
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 BitcoinKit developers
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
// - Using CryptoKit now
// - Changed to a struct instead of a class
// - Removed Fingerprints and Network
// - Removed public

import CryptoKit
import Foundation
import secp256k1

struct HDPrivateKey {
    let depth: UInt8
    let childIndex: UInt32

    let raw: Data
    let chainCode: Data

    init(privateKey: Data, chainCode: Data) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.depth = 0
        self.childIndex = 0
    }

    init(seed: Data) {
        let hmac = HMAC<SHA512>.authenticationCode(for: seed, using: .init(data: "Bitcoin seed".data(using: .ascii)!))
        let hmacData = Data(hmac)
//        let hmac = Crypto.hmacsha512(data: seed, key: "Bitcoin seed".data(using: .ascii)!)
        let privateKey = hmacData[0..<32]
        let chainCode = hmacData[32..<64]
        self.init(privateKey: privateKey, chainCode: chainCode)
    }

    init(privateKey: Data, chainCode: Data, depth: UInt8, childIndex: UInt32) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.depth = depth
        self.childIndex = childIndex
    }

    func privateKey() -> LockPrivateKey {
        return LockPrivateKey(data: raw, isPublicKeyCompressed: false)
    }

    func extendedPublicKey() -> HDPublicKey {
        return HDPublicKey(raw: computePublicKeyData(), chainCode: chainCode, depth: depth, childIndex: childIndex)
    }

    private func computePublicKeyData() -> Data {
        return KeyHelpers.computePublicKey(fromPrivateKey: raw, compression: false)
    }

    func derived(at index: UInt32, hardened: Bool = false) throws -> HDPrivateKey {
        // As we use explicit parameter "hardened", do not allow higher bit set.
        if (0x80000000 & index) != 0 {
            fatalError("invalid child index")
        }

        guard let derivedKey = HDKey(privateKey: raw, publicKey: extendedPublicKey().raw, chainCode: chainCode, depth: depth, childIndex: childIndex).derived(at: index, hardened: hardened) else {
            throw DerivationError.derivationFailed
        }
        return HDPrivateKey(privateKey: derivedKey.privateKey!, chainCode: derivedKey.chainCode, depth: derivedKey.depth, childIndex: derivedKey.childIndex)
    }
}

enum DerivationError: Error {
    case derivationFailed
}
