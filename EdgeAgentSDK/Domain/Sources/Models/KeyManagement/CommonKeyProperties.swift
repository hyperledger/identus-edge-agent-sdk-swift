/// KeyProperties is an enumeration of all possible properties that a cryptographic key can have. Each property is represented as a String value.
public enum KeyProperties: String, CaseIterable {
    /// The 'kid' case represents a key's identifier.
    case kid

    /// The 'type' case denotes the type of the key.
    case type = "type"

    /// The 'algorithm' case corresponds to the cryptographic algorithm associated with the key.
    case algorithm

    /// The 'curve' case represents the elliptic curve used for an elliptic-curve key.
    case curve

    /// The 'seed' case corresponds to the seed value from which a key is derived.
    case seed

    /// The 'rawKey' case refers to the raw binary form of the key.
    case rawKey

    /// The 'curvePointX' case represents the x-coordinate of a curve point for an elliptic-curve key.
    case curvePointX = "curvePoint.x"

    /// The 'curvePointY' case represents the y-coordinate of a curve point for an elliptic-curve key.
    case curvePointY = "curvePoint.y"

    /// The 'derivationPath' case refers to the path used to derive a key in a hierarchical deterministic (HD) key generation scheme.
    case derivationPath
    
    /// The compressed 'rawKey' case refers to the raw binary in compressed form of the key.
    case compressedRaw
}

/// Enumeration representing supported key curves for key generation.
public enum KnownKeyCurves: String, CaseIterable {
    /// The x25519 key curve.
    case x25519

    /// The ed25519 key curve.
    case ed25519

    /// The secp256k1 key curve with an optional index.
    case secp256k1
}
