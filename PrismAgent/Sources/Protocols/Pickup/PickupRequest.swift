import Core
import Domain
import Foundation

struct PickUpRequest {
    struct Body: Codable {
        let recipientKey: String?
        let limit: String

        init(
            recipientKey: String? = nil,
            limit: String
        ) {
            self.recipientKey = recipientKey
            self.limit = limit
        }
    }

    let from: DID
    // swiftlint:disable identifier_name
    let to: DID
    // swiftlint:enable identifier_name
    let body: Body

    func makeMessage() throws -> Message {
        let body = try JSONEncoder.didComm().encode(body)
        return Message(
            piuri: ProtocolTypes.pickupRequest.rawValue,
            from: from,
            to: to,
            body: body
        )
    }
}
