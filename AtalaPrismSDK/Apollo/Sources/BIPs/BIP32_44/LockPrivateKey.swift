//
//  PrivateKey.swift
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
// - Removed wif

import Foundation

struct LockPrivateKey {
    let data: Data
    let isPublicKeyCompressed: Bool

    init(isPublicKeyCompressed: Bool = true) {
        self.isPublicKeyCompressed = isPublicKeyCompressed

        // Check if vch is greater than or equal to max value
        func check(_ vch: [UInt8]) -> Bool {
            let max: [UInt8] = [
                0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE,
                0xBA, 0xAE, 0xDC, 0xE6, 0xAF, 0x48, 0xA0, 0x3B,
                0xBF, 0xD2, 0x5E, 0x8C, 0xD0, 0x36, 0x41, 0x40
            ]
            var fIsZero = true
            for byte in vch where byte != 0 {
                fIsZero = false
                break
            }
            if fIsZero {
                return false
            }
            for (index, byte) in vch.enumerated() {
                if byte < max[index] {
                    return true
                }
                if byte > max[index] {
                    return false
                }
            }
            return true
        }

        let count = 32
        var key = Data(count: count)
        var status: Int32 = 0
        repeat {
            status = key.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, count, $0.baseAddress.unsafelyUnwrapped) }
        } while (status != 0 || !check([UInt8](key)))

        self.data = key
    }

    init(data: Data, isPublicKeyCompressed: Bool = true) {
        self.data = data
        self.isPublicKeyCompressed = isPublicKeyCompressed
    }

    private func computePublicKeyData() -> Data {
        return KeyHelpers.computePublicKey(fromPrivateKey: data, compression: isPublicKeyCompressed)
    }

    func publicKeyPoint() throws -> PointOnCurve {
        let xAndY: Data = KeyHelpers.computePublicKey(fromPrivateKey: data, compression: false)
        let expectedLengthOfScalar = Scalar32Bytes.expectedByteCount
        let expectedLengthOfKey = expectedLengthOfScalar * 2
        guard xAndY.count == expectedLengthOfKey else {
            fatalError("expected length of key is \(expectedLengthOfKey) bytes, but got: \(xAndY.count)")
        }
        let x = xAndY.prefix(expectedLengthOfScalar)
        let y = xAndY.suffix(expectedLengthOfScalar)
        return try PointOnCurve(x: x, y: y)
    }

    func publicKey() -> LockPublicKey {
        return LockPublicKey(bytes: computePublicKeyData())
    }
}

extension LockPrivateKey: Equatable {
    public static func == (lhs: LockPrivateKey, rhs: LockPrivateKey) -> Bool {
        return lhs.data == rhs.data
    }
}

enum PrivateKeyError: Error {
    case invalidFormat
}
