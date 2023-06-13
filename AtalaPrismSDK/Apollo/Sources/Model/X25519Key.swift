import CryptoKit
import Domain
import Foundation

struct X25519PrivateKey: PrivateKey {
    private let appleCurve: Curve25519.KeyAgreement.PrivateKey
    let keyType: String = "EC"
    let keySpecifications: [String : Any] = [
        "curve" : "x25519"
    ]
    var size: Int { raw.count }
    var raw: Data { appleCurve.rawRepresentation }

    init(appleCurve: Curve25519.KeyAgreement.PrivateKey) {
        self.appleCurve = appleCurve
    }

    func publicKey() -> PublicKey {
        X25519PublicKey(appleCurve: appleCurve.publicKey)
    }
}

extension X25519PrivateKey: StorableKey {
    var restorationIdentifier: String { "x25519+prv" }
    var storableData: Data { raw }
}

struct X25519PublicKey: PublicKey {
    private let appleCurve: Curve25519.KeyAgreement.PublicKey
    let keyType: String = "EC"
    let keySpecifications: [String : Any] = [
        "curve" : "x25519"
    ]
    var size: Int { raw.count }
    var raw: Data { appleCurve.rawRepresentation }

    init(appleCurve: Curve25519.KeyAgreement.PublicKey) {
        self.appleCurve = appleCurve
    }

    func verify(data: Data, signature: Data) throws -> Bool {
        throw UnknownError.somethingWentWrongError(
            customMessage: "Only key agreement is supported",
            underlyingErrors: nil
        )
    }
}

extension X25519PublicKey: StorableKey {
    var restorationIdentifier: String { "x25519+pub" }
    var storableData: Data { raw }
}
