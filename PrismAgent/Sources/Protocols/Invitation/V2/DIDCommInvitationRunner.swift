import Domain
import Foundation

class DIDCommInvitationRunner {
    private let mercury: Mercury
    private let url: URL

    init(mercury: Mercury, url: URL) {
        self.mercury = mercury
        self.url = url
    }

    func run() throws -> Message {
        let messageString = try OutOfBandParser().parseMessage(url: url)
        let message = try mercury.unpackMessage(msg: messageString, options: .expectDecryptByAllKeys).result
        guard message.piuri == ProtocolTypes.didcomminvitation.rawValue else {
            throw PrismAgentError.unknownInvitationTypeError
        }
        return message
    }
}