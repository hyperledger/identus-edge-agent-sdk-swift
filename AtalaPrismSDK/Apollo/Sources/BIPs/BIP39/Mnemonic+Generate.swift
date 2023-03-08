//
//  Mnemonic+Generate.swift
//
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
// - Using CryptoKit
// - Removed Public

import Core
import CommonCrypto
import CryptoKit
import Foundation

// MARK: Generate
extension Mnemonic {
    static func generate(strength: Strength = .default, language: Language = .english) throws -> [String] {
        let entropy = try securelyGenerateBytes(count: strength.byteCount)
        return try generate(entropy: entropy, language: language)
    }
}

extension Mnemonic {
    static func generate(
        entropy: Data,
        language: Language = .english
    ) throws -> [String] {

        guard let strength = Mnemonic.Strength(byteCount: entropy.count) else {
            throw Error.unsupportedByteCountOfEntropy(got: entropy.count)
        }

        let words = wordList(for: language)
        let hash = Data(SHA256.hash(data: entropy))

        let checkSumBits = BitArray(data: hash).prefix(strength.checksumLengthInBits)

        let bits = BitArray(data: entropy) + checkSumBits

		let wordIndices = bits.splitIntoChunks(ofSize: Mnemonic.WordList.sizeLog2)
            .map { UInt11(bitArray: $0)! }
            .map { $0.asInt }

        let mnemonic = wordIndices.map { words[$0] }

        try validateChecksumOf(mnemonic: mnemonic, language: language)
        return mnemonic
    }
}

// MARK: To Seed
extension Mnemonic {
    /// Pass a trivial closure: `{ _ in }` to `validateChecksum` if you would like to opt-out of checksum validation.
    static func seed(
        mnemonic words: [String],
        passphrase: String = "",
        validateChecksum: (([String]) throws -> Void) = { try Mnemonic.validateChecksumDerivingLanguageOf(mnemonic: $0) }
    ) throws -> Data {
        try validateChecksum(words)

        let mnemonic = words.joined(separator: " ").decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let salt = ("mnemonic" + passphrase).decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let seed = try deriveSeedHmacAlgSha512(mnemonic, salt: salt, iterations: 2048, keyLength: 64)
        return seed
    }
}

private func deriveSeedHmacAlgSha512(_ password: Data, salt: Data, iterations: Int = 2048, keyLength: Int = 64) throws -> Data {
    var bytes = [UInt8](repeating: 0, count: keyLength)

    let status: Int32 = password.withUnsafeBytes { pptr in
        let passwdPtr = pptr.bindMemory(to: CChar.self)
        return CCKeyDerivationPBKDF(
            CCPBKDFAlgorithm(kCCPBKDF2),
            passwdPtr.baseAddress,
            passwdPtr.count,
            salt.bytes,
            salt.count,
            CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512),
            UInt32(iterations),
            &bytes,
            keyLength
        )
    }

    guard status == kCCSuccess else {
        throw Status(status: status)
    }
    return Data(bytes)
}
