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
    let to: DID
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
