import Core
import Foundation

extension Base64Utils {
    func encodeMethodID(data: Data) -> String {
        data.base64UrlEncodedString()
    }

    func decodeMethodID(str: String) -> Data? {
        return Data(fromBase64URL: str)
    }
}
