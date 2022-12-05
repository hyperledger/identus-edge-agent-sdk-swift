import Foundation

public extension JSONEncoder {
    static func didComm() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .deferredToData
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }
}
