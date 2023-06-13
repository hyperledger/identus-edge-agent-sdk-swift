import CryptoKit
import Domain
import Foundation

struct Ed25519PrivateKey: PrivateKey {
    private let appleCurve: Curve25519.Signing.PrivateKey
    let keyType: String = "EC"
    let keySpecifications: [String : Any] = [
        "curve" : "Ed25519"
    ]
    var size: Int { raw.count }
    var raw: Data { appleCurve.rawRepresentation }

    init(appleCurve: Curve25519.Signing.PrivateKey) {
        self.appleCurve = appleCurve
    }

    func publicKey() -> PublicKey {
        Ed25519PublicKey(appleCurve: appleCurve.publicKey)
    }
}

extension Ed25519PrivateKey: SignableKey {
    var algorithm: String { "EDDSA" }

    func sign(data: Data) throws -> Signature {
        Signature(
            algorithm: "EdDSA",
            signatureSpecifications: ["algorithm" : algorithm],
            raw: try appleCurve.signature(for: data)
        )
    }
}

extension Ed25519PrivateKey: StorableKey {
    var restorationIdentifier: String { "ed25519+prv" }
    var storableData: Data { raw }
}

struct Ed25519PublicKey: PublicKey {
    private let appleCurve: Curve25519.Signing.PublicKey
    let keyType: String = "EC"
    let keySpecifications: [String : Any] = [
        "curve" : "Ed25519"
    ]
    var size: Int { raw.count }
    var raw: Data { appleCurve.rawRepresentation }

    init(appleCurve: Curve25519.Signing.PublicKey) {
        self.appleCurve = appleCurve
    }

    func verify(data: Data, signature: Data) throws -> Bool {
        appleCurve.isValidSignature(signature, for: data)
    }
}

extension Ed25519PublicKey: StorableKey {
    var restorationIdentifier: String { "ed25519+pub" }
    var storableData: Data { raw }
}
