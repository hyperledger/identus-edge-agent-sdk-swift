public struct Secret {
    public enum SecretMaterial {
        case jwk(value: String )
//        case multibase(value: String )
//        case base58(value: String )
//        case hex(value: String )
//        case other(value: String )
    }

    public enum SecretType {
        case jsonWebKey2020
//        case x25519KeyAgreementKey2019
//        case ed25519VerificationKey2018
//        case ecdsaSecp256k1VerificationKey2019
//        case x25519KeyAgreementKey2020
//        case ed25519VerificationKey2020
//        case other
    }

    public var id: String
    public var type: SecretType
    public var secretMaterial: SecretMaterial

    public init(id: String, type: SecretType, secretMaterial: SecretMaterial) {
        self.id = id
        self.type = type
        self.secretMaterial = secretMaterial
    }
}
