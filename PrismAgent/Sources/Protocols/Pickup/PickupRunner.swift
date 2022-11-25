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

    func run() throws -> [Message] {
        try message.attachments.compactMap {
            ($0.data as? AttachmentBase64)?.base64
        }.map {
            try mercury.unpackMessage(msg: $0, options: .unwrapReWrappingForward).result
        }
    }
}
