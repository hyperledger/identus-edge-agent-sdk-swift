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
        let messageString = try OutOfBandParser().parseMessage(url: url)
        return try await mercury.unpackMessage(msg: messageString)
    }
}
