import Domain
import Foundation

class InvitationRunner {
    private let mercury: Mercury
    private let url: URL

    init(mercury: Mercury, url: URL) {
        self.mercury = mercury
        self.url = url
    }

    func run() async throws -> Message {
        let messageData = try OutOfBandParser().parseMessage(url: url)
        guard
            let messageString = String(data: messageData, encoding: .utf8)
        else { throw UnknownError.somethingWentWrongError() }
        return try await mercury.unpackMessage(msg: messageString)
    }
}
