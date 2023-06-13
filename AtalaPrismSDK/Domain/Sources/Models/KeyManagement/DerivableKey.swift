import Foundation

public struct DerivationPath {
    public let index: Int

    /// Initializes a KeyPath by giving it an Index
    public init(index: Int) {
        self.index = index
    }

    public init(string: String) throws {
        let pattern = "^m(\\/\\d+'?)+$"
        let validationRegex = try NSRegularExpression(pattern: pattern, options: [])
        guard !validationRegex.matches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.utf16.count)
        ).isEmpty else { throw UnknownError.somethingWentWrongError() }

        let parsingRegex = try NSRegularExpression(pattern: "\\d+", options: [])
        let matches = parsingRegex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))

        guard let firstMatch = matches.first else { throw UnknownError.somethingWentWrongError() }
        let range = Range(firstMatch.range, in: string)!
        guard let index = Int(String(string[range])) else { throw UnknownError.somethingWentWrongError() }
        self.index = index
    }

    public func keyPathString() -> String {
        return "m/\(index)'/0'/0'"
    }
}

public protocol DerivableKey {
    func deriveKey(withPublicKey otherPublicKey: PublicKey, salt: Data?) throws -> Data
    func deriveKey(usingDerivationPath path: DerivationPath) throws -> Key
}

public extension Key {
    var isDerivable: Bool { self is DerivableKey }
    var derivable: DerivableKey? { self as? DerivableKey }
}
