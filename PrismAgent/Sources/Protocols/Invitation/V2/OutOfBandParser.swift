import Core
import Foundation

struct OutOfBandParser {
    func parseMessage(url: URL) throws -> String {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { throw PrismAgentError.invalidURLError }
        guard let message = components
            .queryItems?
            .first(where: { $0.name == "_oob" })?
            .value,
            let dataJson = Data(base64URLEncoded: message),
            let stringJson = String(data: dataJson, encoding: .utf8)
        else { throw PrismAgentError.invalidURLError }

        return stringJson
    }
}
