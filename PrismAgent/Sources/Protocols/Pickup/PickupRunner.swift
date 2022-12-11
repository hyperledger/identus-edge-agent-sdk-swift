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

    func run() async throws -> [(message: Message, attachmentId: String)] {
        switch message {
        case let .delivery(message):
            return try await message.attachments.compactMap { attachment in
                switch attachment.data {
                case let json as AttachmentJsonData:
                    return String(data: json.data, encoding: .utf8).map { ($0, attachment.id) }
                default:
                    return nil
                }
            }
            .asyncMap { messageString, id in
                (try await mercury.unpackMessage(msg: messageString), id)
            }
        case .status:
            return []
        }
    }
}
