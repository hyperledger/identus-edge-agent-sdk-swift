import Domain
import Foundation

struct HandshakeRequest {
    // Connection Body is the same as Invitation body message
    struct Body: Codable {
        let goalCode: String?
        let goal: String?
        let accept: [String]

        init(
            goalCode: String? = nil,
            goal: String? = nil,
            accept: [String] = []
        ) {
            self.goalCode = goalCode
            self.goal = goal
            self.accept = accept
        }
    }
    let type: String = ProtocolTypes.didcommconnectionRequest.rawValue
    let id: String
    let from: DID
    // swiftlint:disable identifier_name
    let to: DID
    // swiftlint:enable identifier_name
    let thid: String?
    let body: Body

    init(inviteMessage: Message, from: DID) throws {
        guard let toDID = inviteMessage.from else { throw PrismAgentError.invitationIsInvalidError }
        let body = try JSONDecoder().decode(Body.self, from: inviteMessage.body)
        self.init(from: from, to: toDID, thid: inviteMessage.id, body: body)
    }

    init(
        id: String = UUID().uuidString,
        from: DID,
        // swiftlint:disable identifier_name
        to: DID,
        // swiftlint:enable identifier_name
        thid: String?,
        body: Body
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.thid = thid
        self.body = body
    }

    func makeMessage() throws -> Message {
        Message(
            id: id,
            piuri: type,
            from: from,
            to: to,
            body: try JSONEncoder().encode(self.body),
            thid: thid
        )
    }
}
