import Core
import Domain
import Foundation

class DIDCommInvitationRunner {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func run() throws -> OutOfBandInvitation {
        let messageData = try OutOfBandParser().parseMessage(url: url)
        let message = try JSONDecoder.didComm().decode(OutOfBandInvitation.self, from: messageData)
        guard message.type == ProtocolTypes.didcomminvitation.rawValue else {
            throw EdgeAgentError.unknownInvitationTypeError
        }
        return message
    }
}
