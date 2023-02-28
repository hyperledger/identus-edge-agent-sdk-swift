import Core
import Domain
import Foundation

struct MediationKeysUpdateList {
    struct Body: Encodable {
        struct Update: Encodable {
            let recipientDid: String
            let action = "add"
        }
        let updates: [Update]
    }

    let id: String
    let from: DID
    let to: DID
    let type = ProtocolTypes.didcommMediationKeysUpdate.rawValue
    let body: Body

    init(
        id: String = UUID().uuidString,
        from: DID,
        to: DID,
        recipientDids: [DID]
    ) {
        self.id = id
        self.from = from
        self.to = to
        print(recipientDids.map { $0.string })
        self.body = .init(
            updates: recipientDids.map {
                Body.Update(recipientDid: $0.string)
            }
        )
    }

    func makeMessage() throws -> Message {
        return Message(
            id: id,
            piuri: type,
            from: from,
            to: to,
            body: try JSONEncoder.didComm().encode(body)
        )
    }
}
