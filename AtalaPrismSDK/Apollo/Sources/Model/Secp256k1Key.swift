import Domain
import CryptoKit
import Foundation

struct Secp256k1PrivateKey: PrivateKey {
    private let lockedPrivateKey: LockPrivateKey

    let keyType: String = "EC"
    let keySpecifications: [String : String]
    let size: Int
    let raw: Data

    init(lockedPrivateKey: LockPrivateKey) {
        self.lockedPrivateKey = lockedPrivateKey
        self.keySpecifications = [
            KeyProperties.curve.rawValue : "secp256k1"
        ]

        self.raw = lockedPrivateKey.data
        self.size = lockedPrivateKey.data.count
    }

    func publicKey() -> PublicKey {
        Secp256k1PublicKey(lockedPublicKey: lockedPrivateKey.publicKey())
    }
}

extension Secp256k1PrivateKey: SignableKey {
    var algorithm: String { "ECDSA+SHA256" }

    func sign(data: Data) throws -> Signature {
        Signature(
            algorithm: algorithm,
            signatureSpecifications: ["algorithm" : algorithm],
            raw: try ECSigning(data: Data(SHA256.hash(data: data)), privateKey: raw).signMessage()
        )
    }
}

extension Secp256k1PrivateKey: StorableKey {
    var securityLevel: SecurityLevel { SecurityLevel.high }
    var restorationIdentifier: String { "secp256k1+priv" }
    var storableData: Data { raw }
}

struct Secp256k1PublicKey: PublicKey {
    private let lockedPublicKey: LockPublicKey

    let keyType: String = "EC"
    let keySpecifications: [String : String]
    let size: Int
    let raw: Data

    init(lockedPublicKey: LockPublicKey) {
        self.lockedPublicKey = lockedPublicKey
        var specs: [String: String] = [
            KeyProperties.curve.rawValue: "secp256k1",
            "compressed": lockedPublicKey.isCompressed ? "true" : "false"
        ]
        if let points = try? lockedPublicKey.pointCurve() {
            specs[KeyProperties.curvePointX.rawValue] = points.x.data.base64EncodedString()
            specs[KeyProperties.curvePointY.rawValue] = points.y.data.base64EncodedString()
        }
        self.keySpecifications = specs
        self.size = lockedPublicKey.data.count
        self.raw = lockedPublicKey.data
    }

    func verify(data: Data, signature: Data) throws -> Bool {
        try ECVerify(
            signature: signature,
            message: data,
            publicKey: raw
        ).verifySignature()
    }
}

extension Secp256k1PublicKey: StorableKey {
    var securityLevel: SecurityLevel { SecurityLevel.low }
    var restorationIdentifier: String { "secp256k1+pub" }
    var storableData: Data { raw }
}
