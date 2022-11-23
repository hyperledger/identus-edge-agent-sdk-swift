import Foundation

struct OutOfBandParser {
    func parseMessage(url: URL) throws -> String {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { throw PrismAgentError.invalidURLError }
        guard let message = components
            .queryItems?
            .first(where: { $0.name == "_oob" })?
            .value
        else { throw PrismAgentError.invalidURLError }
        return message
    }
}
