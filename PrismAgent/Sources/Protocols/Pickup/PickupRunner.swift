import Core
import Domain
import Foundation

class PickupRunner {
    private let message: Message
    private let mercury: Mercury

    init(message: Message, mercury: Mercury) throws {
        guard
            message.piuri == ProtocolTypes.pickupDelivery.rawValue
        else { throw PrismAgentError.invalidPickupDeliveryMessageError }
        self.message = message
        self.mercury = mercury
    }

    func run() async throws -> [Message] {
        try await message.attachments.compactMap {
            ($0.data as? AttachmentBase64)?.base64
        }.asyncMap {
            try await mercury.unpackMessage(msg: $0)
        }
    }
}
