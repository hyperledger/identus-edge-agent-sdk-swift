import CryptoKit
import Domain
import Foundation

struct X25519PrivateKey: PrivateKey {
    private let appleCurve: Curve25519.KeyAgreement.PrivateKey
    let keyType: String = "EC"
    let keySpecifications: [String : String] = [
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

extension X25519PrivateKey: KeychainStorableKey {
    var restorationIdentifier: String { "x25519+priv" }
    var storableData: Data { raw }
    var index: Int? { nil }
    var type: Domain.KeychainStorableKeyProperties.KeyAlgorithm { .rawKey }
    var keyClass: Domain.KeychainStorableKeyProperties.KeyType { .privateKey }
    var accessiblity: Domain.KeychainStorableKeyProperties.Accessability? { .firstUnlock(deviceOnly: true) }
    var synchronizable: Bool { false }
}

struct X25519PublicKey: PublicKey {
    private let appleCurve: Curve25519.KeyAgreement.PublicKey
    let keyType: String = "EC"
    let keySpecifications: [String : String] = [
        "curve" : "x25519"
    ]
    var size: Int { raw.count }
    var raw: Data { appleCurve.rawRepresentation }

    init(appleCurve: Curve25519.KeyAgreement.PublicKey) {
        self.appleCurve = appleCurve
    }

    func verify(data: Data, signature: Data) throws -> Bool {
        throw ApolloError.keyAgreementDoesNotSupportVerification
    }
}

extension X25519PublicKey: KeychainStorableKey {
    var restorationIdentifier: String { "x25519+pub" }
    var storableData: Data { raw }
    var index: Int? { nil }
    var type: Domain.KeychainStorableKeyProperties.KeyAlgorithm { .rawKey }
    var keyClass: Domain.KeychainStorableKeyProperties.KeyType { .publicKey }
    var accessiblity: Domain.KeychainStorableKeyProperties.Accessability? { .firstUnlock(deviceOnly: true) }
    var synchronizable: Bool { false }
}
