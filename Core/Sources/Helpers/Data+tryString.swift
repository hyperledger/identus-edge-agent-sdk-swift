import Domain
import Foundation

public extension Data {
    func toString(using: String.Encoding = .utf8) throws -> String {
        guard let str = String(data: self, encoding: using) else {
            throw CommonError.invalidCoding(message: "Could not get String from Data value")
        }
        return str
    }
}
