import Foundation

public extension JSONDecoder {
    static func didComm() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .deferredToData
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
