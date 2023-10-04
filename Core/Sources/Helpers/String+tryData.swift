import Domain
import Foundation

public extension String {
    func tryData(using: String.Encoding) throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw CommonError.invalidCoding(message: "Could not encode to Data")
        }
        return data
    }
}
