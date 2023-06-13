import Foundation

/// `DerivationPath` is a structure that represents the path for key derivation in hierarchical deterministic (HD) wallets.
public struct DerivationPath {
    /// The index of the key in the path.
    public let index: Int

    /// Creates a new `DerivationPath` instance from a given index.
    /// - Parameter index: The index of the key in the path.
    public init(index: Int) {
        self.index = index
    }

    /// Creates a new `DerivationPath` instance from a path string.
    /// - Parameter string: A string representation of the path.
    /// - Throws: `CommonError.invalidRegex` if the path string cannot be parsed.
    public init(string: String) throws {
        let pattern = "^m(\\/\\d+'?)+$"
        let validationRegex = try NSRegularExpression(pattern: pattern, options: [])
        guard !validationRegex.matches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.utf16.count)
        ).isEmpty else { throw CommonError.invalidRegex(regex: pattern, invalid: string) }

        let parsingRegex = try NSRegularExpression(pattern: "\\d+", options: [])
        let matches = parsingRegex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))

        guard let firstMatch = matches.first else { throw CommonError.invalidRegex(regex: pattern, invalid: string) }
        let range = Range(firstMatch.range, in: string)!
        guard let index = Int(String(string[range])) else { throw CommonError.invalidRegex(regex: pattern, invalid: string) }
        self.index = index
    }

    /// Returns a string representation of this `DerivationPath`.
    /// - Returns: A string in the format of "m/<index>'/0'/0'".
    public func keyPathString() -> String {
        return "m/\(index)'/0'/0'"
    }
}

/// `DerivableKey` is a protocol that defines functionality for keys that can be derived using a `DerivationPath`.
public protocol DerivableKey {
    func deriveKey(withPublicKey otherPublicKey: PublicKey, salt: Data?) throws -> Data
    func deriveKey(usingDerivationPath path: DerivationPath) throws -> Key
}

/// Extension to add derivable functionality to `Key`.
public extension Key {
    /// A Boolean value indicating whether the key is derivable.
    var isDerivable: Bool { self is DerivableKey }

    /// Returns the derivable representation of the key.
    var derivable: DerivableKey? { self as? DerivableKey }
}
