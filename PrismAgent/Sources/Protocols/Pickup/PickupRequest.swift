import Domain
import Foundation

struct PickUpRequest {
    struct Body: Codable {
        let recipient_key: String?
        let limit: String

        init(
            recipient_key: String? = nil,
            limit: String
        ) {
            self.recipient_key = recipient_key
            self.limit = limit
        }
    }

    let from: DID
    // swiftlint:disable identifier_name
    let to: DID
    // swiftlint:enable identifier_name
    let body: Body

    func makeMessage() -> Message {
        guard let body = try? JSONEncoder().encode(body) else {
            fatalError("Not supposed to happen")
        }
        return Message(
            piuri: ProtocolTypes.pickupRequest.rawValue,
            from: from,
            to: to,
            body: body
        )
    }
}
