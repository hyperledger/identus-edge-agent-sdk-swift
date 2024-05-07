public enum ValidECCurves: String, CaseIterable {
    case secp256k1
    case ed25519
    case x25519
}

public enum ValidCryptographicTypes: String, CaseIterable {
    case ec = "EC"
}
