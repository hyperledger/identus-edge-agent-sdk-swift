import Core
import Domain
import Foundation

class DIDCommInvitationRunner {
    private let mercury: Mercury
    private let url: URL

    init(mercury: Mercury, url: URL) {
        self.mercury = mercury
        self.url = url
    }

    func run() async throws -> OutOfBandInvitation {
        let messageData = try OutOfBandParser().parseMessage(url: url)
        let message = try JSONDecoder.didComm().decode(OutOfBandInvitation.self, from: messageData)
        guard message.type == ProtocolTypes.didcomminvitation.rawValue else {
            throw PrismAgentError.unknownInvitationTypeError
        }
        return message
    }
}
