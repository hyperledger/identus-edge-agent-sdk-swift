import Core
import Domain
import Foundation

class PickupRunner {
    enum PickupResponse {
        case status(Message)
        case delivery(Message)
    }
    private let message: PickupResponse
    private let mercury: Mercury

    init(message: Message, mercury: Mercury) throws {
        switch message.piuri {
        case ProtocolTypes.pickupStatus.rawValue:
            self.message = .status(message)
        case ProtocolTypes.pickupDelivery.rawValue:
            self.message = .delivery(message)
        default:
            throw PrismAgentError.invalidPickupDeliveryMessageError
        }
        self.mercury = mercury
    }

    func run() async throws -> [Message] {
        switch message {
        case let .delivery(message):
            return try await message.attachments.compactMap {
                ($0.data as? AttachmentBase64)?.base64
            }.asyncMap {
                try await mercury.unpackMessage(msg: $0)
            }
        case .status:
            return []
        }
    }
}
