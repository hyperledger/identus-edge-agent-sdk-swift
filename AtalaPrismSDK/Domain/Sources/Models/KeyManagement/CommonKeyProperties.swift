public enum KeyProperties: String, CaseIterable {
    case kid
    case type = "type"
    case algorithm
    case curve
    case seed
    case rawKey
    case curvePointX = "curvePoint.x"
    case curvePointY = "curvePoint.y"
    case derivationPath
}

/// Enumeration representing supported key curves for key generation.
public enum KnownKeyCurves: String {
    /// The x25519 key curve.
    case x25519

    /// The ed25519 key curve.
    case ed25519

    /// The secp256k1 key curve with an optional index.
    case secp256k1
}
