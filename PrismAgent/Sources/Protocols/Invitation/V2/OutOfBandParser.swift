import Core
import Foundation

struct OutOfBandParser {
    func parseMessage(url: URL) throws -> Data {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { throw PrismAgentError.invalidURLError }
        guard let message = components
            .queryItems?
            .first(where: { $0.name == "_oob" })?
            .value,
            let dataJson = Data(base64URLEncoded: message)
        else { throw PrismAgentError.invalidURLError }

        return dataJson
    }
}
