import Foundation

public extension JSONEncoder {
    static func didComm() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .withoutEscapingSlashes
        return encoder
    }
}
