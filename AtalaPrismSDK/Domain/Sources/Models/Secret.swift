/// Represents a secret, which is a piece of secret material and its type.
public struct Secret {
    /// Enumeration representing the secret material.
    public enum SecretMaterial {
        /// The secret material is a JSON web key (JWK).
        case jwk(value: String)
    }

    /// Enumeration representing the secret type.
    public enum SecretType {
        /// The secret type is a JSON web key (JWK) as specified in [RFC7517](https://tools.ietf.org/html/rfc7517).
        case jsonWebKey2020
    }

    /// The ID of the secret.
    public var id: String

    /// The type of the secret
    public var type: SecretType

    /// The secret material
    public var secretMaterial: SecretMaterial

    public init(id: String, type: SecretType, secretMaterial: SecretMaterial) {
        self.id = id
        self.type = type
        self.secretMaterial = secretMaterial
    }
}
