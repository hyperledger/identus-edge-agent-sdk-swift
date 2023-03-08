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

    /**
     * Guarantees to init a public key uncompressed with 65 bytes in the following form:
     *
     * 0x04 ++ xBytes ++ yBytes
     *
     * Where `xBytes` and `yBytes` represent a 32-byte coordinates of a point
     * on the secp256k1 elliptic curve, which follow the formula below:
     *
     * y^2 == x^3 + 7
     *
     * @return uncompressed public key
     */
    init(x: Data, y: Data) {
        let header: UInt8 = 0x04
        self.data = [header] + x + y
        self.isCompressed = false
    }

    func compressedPublicKey() -> LockPublicKey {
        LockPublicKey(bytes: KeyHelpers.compressPublicKey(fromPublicKey: data))
    }

    func uncompressedPublicKey() -> LockPublicKey {
        LockPublicKey(bytes: KeyHelpers.uncompressPublicKey(fromPublicKey: data))
    }

    func pointCurve() throws -> PointOnCurve {
        let selfUncompressed = uncompressedPublicKey()
        var xAndY = selfUncompressed.data
        xAndY.removeFirst() // Remove the header
        let expectedLengthOfScalar = Scalar32Bytes.expectedByteCount
        let expectedLengthOfKey = expectedLengthOfScalar * 2
        guard xAndY.count == expectedLengthOfKey else {
            fatalError("expected length of key is \(expectedLengthOfKey) bytes, but got: \(xAndY.count)")
        }
        let x = xAndY.prefix(expectedLengthOfScalar)
        let y = xAndY.suffix(expectedLengthOfScalar)
        return try PointOnCurve(x: x, y: y)
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
