import Foundation

public struct Base64Utils {
    public init() {}

    public func encode(_ data: Data) -> String {
        String(data.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .trimingTrailing(while: CharacterSet(charactersIn: "=")))
    }

    public func decode(_ src: String) -> Data? {
        let expectedLength = (src.count + 3) / 4 * 4
        let base64Encoded = src
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
            .appending(String(repeating: .init("="), count: expectedLength))
        return Data(base64Encoded: base64Encoded)
    }
}

public extension Data {
    func base64UrlEncodedString() -> String {
        Base64Utils().encode(self)
    }

    init?(fromBase64URL: String) {
        guard let data = Base64Utils().decode(fromBase64URL) else {
            return nil
        }
        self = data
    }
}

private extension String {
    func trimingTrailing(while characterSet: CharacterSet) -> String {
        guard
            let index = lastIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: characterSet) })
        else { return self }

        return String(self[...index])
    }
}
