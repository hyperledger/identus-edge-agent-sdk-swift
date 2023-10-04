import Foundation

/// The `ExportableKey` protocol defines a cryptographic key that can be exported in different formats.
public protocol ExportableKey {
    /// The key exported in PEM (Privacy-Enhanced Mail) format.
    var pem: String { get }

    /// The key exported as a JSON Web Key (JWK).
    var jwk: JWK { get }

    /// Returns the key as a JWK with a specific key identifier (kid).
    func jwkWithKid(kid: String) -> JWK
}

/// The `ImportableKey` protocol defines a cryptographic key that can be created from different import formats.
public protocol ImportableKey {
    /// Initializes a key from a PEM string.
    init(pem: String) throws

    /// Initializes a key from a JWK.
    init(jwk: JWK) throws
}

/// Extension of the `Key` protocol to provide additional functionality related to exporting and importing.
public extension Key {
    /// A boolean value indicating whether the key can be exported.
    var isExportable: Bool { self is ExportableKey }

    /// Returns this key as an `ExportableKey`, or `nil` if the key cannot be exported.
    var exporting: ExportableKey? { self as? ExportableKey }

    /// A boolean value indicating whether the key can be imported.
    var isImportable: Bool { self is ImportableKey }

    /// Returns this key as an `ImportableKey`, or `nil` if the key cannot be imported.
    var importing: ImportableKey? { self as? ImportableKey }
}

/// The `JWK` structure represents a JSON Web Key.
public struct JWK {
    /// Key parameters
    public let kty: String
    public let alg: String?
    public let kid: String?
    public let use: String?

    /// RSA key parameters
    public let n: String?
    public let e: String?
    public let d: String?
    public let p: String?
    public let q: String?
    public let dp: String?
    public let dq: String?
    public let qi: String?

    /// EC key parameters
    public let crv: String?
    public let x: String?
    public let y: String?

    /// Symmetric key parameters
    public let k: String?

    public init(
        kty: String,
        alg: String? = nil,
        kid: String? = nil,
        use: String? = nil,
        n: String? = nil,
        e: String? = nil,
        d: String? = nil,
        p: String? = nil,
        q: String? = nil,
        dp: String? = nil,
        dq: String? = nil,
        qi: String? = nil,
        crv: String? = nil,
        x: String? = nil,
        y: String? = nil,
        k: String? = nil
    ) {
        self.kty = kty
        self.alg = alg
        self.kid = kid
        self.use = use
        self.n = n
        self.e = e
        self.d = d
        self.p = p
        self.q = q
        self.dp = dp
        self.dq = dq
        self.qi = qi
        self.crv = crv
        self.x = x
        self.y = y
        self.k = k
    }
}

extension JWK: Codable {
    enum CodingKeys: String, CodingKey {
        case kty
        case alg
        case kid
        case use
        case n
        case e
        case d
        case p
        case q
        case dp
        case dq
        case qi
        case crv
        case x
        case y
        case k
    }
}

/// The `PEMKey` structure represents a cryptographic key in PEM (Privacy-Enhanced Mail) format.
public struct PEMKey {
    /// The type of the key. This corresponds to the type string found in the PEM encoding, such as 'RSA PRIVATE KEY' or 'PUBLIC KEY'.
    public let keyType: String

    /// The raw data representation of the key. This is the actual binary data for the key.
    public let keyData: Data

    /// Creates a `PEMKey` instance with the provided key type and raw key data.
    /// - Parameters:
    ///   - keyType: The type of the key. This corresponds to the type string found in the PEM encoding.
    ///   - keyData: The raw data representation of the key.
    public init(keyType: String, keyData: Data) {
        self.keyType = keyType
        self.keyData = keyData
    }
}

/// Extension to provide additional functionality to the `PEMKey` structure.
extension PEMKey {
    /// Creates a new `PEMKey` instance from a PEM-encoded string.
    /// - Parameter pemString: A string representing a PEM-encoded key.
    /// - Returns: A new `PEMKey` instance, or `nil` if the string could not be decoded properly.
    public init?(pemEncoded pemString: String) {
        let lines = pemString.split(separator: "\n").map { String($0) }
        guard lines.count >= 2 else { return nil }

        let beginMarker = lines[0]
        let endMarker = lines[lines.count - 1]

        guard beginMarker.hasPrefix("-----BEGIN ") && beginMarker.hasSuffix("-----"),
              endMarker.hasPrefix("-----END ") && endMarker.hasSuffix("-----") else {
            return nil
        }

        let keyType = beginMarker.dropFirst(11).dropLast(5)
        let base64Data = lines[1..<(lines.count - 1)].joined()
        guard let keyData = Data(base64Encoded: base64Data) else { return nil }

        self.init(keyType: String(keyType), keyData: keyData)
    }

    /// Returns a PEM-encoded string representation of this `PEMKey`.
    /// - Returns: A string representing this key in PEM format.
    public func pemEncoded() -> String {
        let base64Data = keyData.base64EncodedString()
        let beginMarker = "-----BEGIN \(keyType)-----"
        let endMarker = "-----END \(keyType)-----"

        return [beginMarker, base64Data, endMarker].joined(separator: "\n")
    }
}

