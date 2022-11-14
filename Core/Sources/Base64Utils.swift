import Foundation

public struct Base64Utils {
    public init() {}

    public func encode(_ data: Data) -> String {
        String(data.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .dropLast(1))
    }

    public func decode(_ src: String) -> Data? {
        let base64Encoded = src
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
            + "="
        return Data(base64Encoded: base64Encoded)
    }
}
