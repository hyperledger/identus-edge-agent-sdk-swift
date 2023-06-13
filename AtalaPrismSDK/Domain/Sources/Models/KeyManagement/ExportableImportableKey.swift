import Foundation

public protocol ExportableKey {
    var pem: String { get }
    var jwk: JWK { get }
    func jwkWithKid(kid: String) -> JWK
}

public protocol ImportableKey {
    init(pem: String) throws
    init(jwk: JWK) throws
}

public extension Key {
    var isExportable: Bool { self is ExportableKey }
    var exporting: ExportableKey? { self as? ExportableKey }

    var isImportable: Bool { self is ExportableKey }
    var importing: ImportableKey? { self as? ImportableKey }
}

public struct JWK {
    public let kty: String
    public let alg: String?
    public let kid: String?
    public let use: String?

    public let n: String?
    public let e: String?
    public let d: String?
    public let p: String?
    public let q: String?
    public let dp: String?
    public let dq: String?
    public let qi: String?

    public let crv: String?
    public let x: String?
    public let y: String?

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
    public enum CodingKeys: String, CodingKey {
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

public struct PEMKey {
    public let keyType: String
    public let keyData: Data

    public init(keyType: String, keyData: Data) {
        self.keyType = keyType
        self.keyData = keyData
    }
}

extension PEMKey {
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

    public func pemEncoded() -> String {
        let base64Data = keyData.base64EncodedString(options: [.lineLength64Characters])
        let beginMarker = "-----BEGIN \(keyType)-----"
        let endMarker = "-----END \(keyType)-----"

        return [beginMarker, base64Data, endMarker].joined(separator: "\n")
    }
}
