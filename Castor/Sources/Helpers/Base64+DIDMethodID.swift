import Core
import Foundation

extension Base64Utils {
    func encodeMethodID(data: Data) -> String {
        encode(data)
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .trimingTrailing(while: CharacterSet(charactersIn: "="))
    }

    func decodeMethodID(str: String) -> Data? {
        let expectedLength = (str.count + 3) / 4 * 4
        return decode(str
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
            .appending(String(repeating: .init("="), count: expectedLength))
        )
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
