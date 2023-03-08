//
//  HDPublicKey.swift
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

import Foundation

struct HDPublicKey {
    let depth: UInt8
    let childIndex: UInt32

    let raw: Data
    let chainCode: Data

    init(raw: Data, chainCode: Data, depth: UInt8, childIndex: UInt32) {
        self.raw = raw
        self.chainCode = chainCode
        self.depth = depth
        self.childIndex = childIndex
    }

    func publicKey() -> LockPublicKey {
        return LockPublicKey(bytes: raw)
    }

    func derived(at index: UInt32) throws -> HDPublicKey {
        // As we use explicit parameter "hardened", do not allow higher bit set.
        if (0x80000000 & index) != 0 {
            fatalError("invalid child index")
        }
        guard let derivedKey = HDKey(privateKey: nil, publicKey: raw, chainCode: chainCode, depth: depth, childIndex: childIndex).derived(at: index, hardened: false) else {
            throw DerivationError.derivationFailed
        }
        return HDPublicKey(raw: derivedKey.publicKey, chainCode: derivedKey.chainCode, depth: derivedKey.depth, childIndex: derivedKey.childIndex)
    }
}
