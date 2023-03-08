//
//  PublicKey.swift
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
// - Removed Fingerprints and Network
// - Remove the public
// - Changed name

import Foundation

struct LockPublicKey {
    let data: Data
    let isCompressed: Bool

    init(bytes data: Data) {
        self.data = data
        let header = data[0]
        self.isCompressed = (header == 0x02 || header == 0x03)
    }

    func compressedPublicKey() -> LockPublicKey {
        LockPublicKey(bytes: KeyHelpers.compressPublicKey(fromPublicKey: data))
    }

    func uncompressedPublicKey() -> LockPublicKey {
        LockPublicKey(bytes: KeyHelpers.uncompressPublicKey(fromPublicKey: data))
    }
}

extension LockPublicKey: Equatable {
    static func == (lhs: LockPublicKey, rhs: LockPublicKey) -> Bool {
        return lhs.data == rhs.data
    }
}

extension LockPublicKey: CustomStringConvertible {
    var description: String {
        return data.base64UrlEncodedString()
    }
}
