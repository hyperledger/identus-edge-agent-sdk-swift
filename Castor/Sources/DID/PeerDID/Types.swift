import Foundation

enum VerificationMaterialFormatPeerDID {
    case jwk
}

protocol VerificationMethodTypePeerDID {
    var value: String { get }
}

enum VerificationMethodTypeAgreement: String, VerificationMethodTypePeerDID {
    case jsonWebKey2020 = "JsonWebKey2020"
    case x25519KeyAgreementKey2019 = "X25519KeyAgreementKey2019"
    case x25519KeyAgreementKey2020 = "X25519KeyAgreementKey2020"

    var value: String { self.rawValue }
}

enum VerificationMethodTypeAuthentication: String, VerificationMethodTypePeerDID {
    case jsonWebKey2020 = "JsonWebKey2020"
    case ed25519KeyAgreementKey2018 = "Ed25519VerificationKey2018"
    case ed25519KeyAgreementKey2020 = "Ed25519VerificationKey2020"

    var value: String { self.rawValue }
}

extension VerificationMethodTypePeerDID {
    var agreement: VerificationMethodTypeAgreement? {
        self as? VerificationMethodTypeAgreement
    }
    var authentication: VerificationMethodTypeAuthentication? {
        self as? VerificationMethodTypeAuthentication
    }
}

protocol VerificationMaterialPeerDID {
    var keyType: VerificationMethodTypePeerDID { get }
    var value: String { get }
}

extension VerificationMaterialPeerDID {
    var agreement: VerificationMaterialAgreement? {
        self as? VerificationMaterialAgreement
    }
    var authentication: VerificationMaterialAuthentication? {
        self as? VerificationMaterialAuthentication
    }
}

struct VerificationMaterialAgreement: VerificationMaterialPeerDID {
    let format: VerificationMaterialFormatPeerDID
    let value: String
    let type: VerificationMethodTypeAgreement

    var keyType: VerificationMethodTypePeerDID { type }
}

struct VerificationMaterialAuthentication: VerificationMaterialPeerDID {
    let format: VerificationMaterialFormatPeerDID
    let value: String
    let type: VerificationMethodTypeAuthentication

    var keyType: VerificationMethodTypePeerDID { type }
}

typealias JSON = String
