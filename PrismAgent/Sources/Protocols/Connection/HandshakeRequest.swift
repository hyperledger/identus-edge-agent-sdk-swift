import Core
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
    let to: DID
    let thid: String?
    let body: Body

    init(inviteMessage: Message, from: DID) throws {
        guard let toDID = inviteMessage.from else { throw PrismAgentError.invitationIsInvalidError }
        let body = try JSONDecoder.didComm().decode(Body.self, from: inviteMessage.body)
        self.init(from: from, to: toDID, thid: inviteMessage.id, body: body)
    }

    init(inviteMessage: OutOfBandInvitation, from: DID) throws {
        let toDID = try DID(string: inviteMessage.from)
        self.init(
            from: from,
            to: toDID,
            thid: inviteMessage.id,
            body: .init(
                goalCode: inviteMessage.body.goalCode,
                goal: inviteMessage.body.goal,
                accept: inviteMessage.body.accept
            )
        )
    }

    init(
        id: String = UUID().uuidString,
        from: DID,
        to: DID,
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
            body: try JSONEncoder.didComm().encode(self.body),
            thid: thid
        )
    }
}
