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

    func run() async throws -> [(attachmentId: String, message: Message)] {
        switch message {
        case let .delivery(message):
            return try await message.attachments.compactMap { attachment in
                switch attachment.data {
                case let base64 as AttachmentBase64:
                    return (base64.base64, attachment.id)
                case let json as AttachmentJsonData:
                    return String(data: json.data, encoding: .utf8).map { ($0, attachment.id) }
                default:
                    return nil
                }
            }
            .asyncMap { messageString, id in
                (id, try await mercury.unpackMessage(msg: messageString))
            }
        case .status:
            return []
        }
    }
}
