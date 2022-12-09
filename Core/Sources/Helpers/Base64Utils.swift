import Foundation

public struct Base64Utils {
    public init() {}

    public func encode(_ data: Data) -> String {
        let base64 = data.base64EncodedString()
        return String(base64
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .trimingTrailing(while: CharacterSet(charactersIn: "=")))
    }

    public func decode(_ src: String) -> Data? {
        let expectedLength = src.count % 4
        let replaced = src
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")

        if expectedLength > 0 {
            return Data(base64Encoded: replaced + String(repeating: "=", count: 4 - expectedLength))
        } else {
            return Data(base64Encoded:replaced)
        }
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

    init?(fromBase64URL: Data) {
        guard
            let str = String(data: fromBase64URL, encoding: .utf8),
            let data = Base64Utils().decode(str)
        else { return nil }
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
