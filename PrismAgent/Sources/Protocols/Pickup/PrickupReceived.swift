import Core
import Domain
import Foundation

struct PickUpReceived {
    struct Body: Codable {
        let messageIdList: [String]

        init(messageIdList: [String] = []) {
            self.messageIdList = messageIdList
        }
    }

    let from: DID
    let to: DID
    let body: Body

    func makeMessage() throws -> Message {
        let body = try JSONEncoder.didComm().encode(body)
        return Message(
            piuri: ProtocolTypes.pickupReceived.rawValue,
            from: from,
            to: to,
            body: body
        )
    }
}
