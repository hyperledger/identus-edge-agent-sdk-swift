import Core
import Domain
import Foundation

public struct ConnectionRequest {
    // Connection Body is the same as Invitation body message
    public struct Body: Codable {
        public let goalCode: String?
        public let goal: String?
        public let accept: [String]?

        public init(
            goalCode: String? = nil,
            goal: String? = nil,
            accept: [String]? = nil
        ) {
            self.goalCode = goalCode
            self.goal = goal
            self.accept = accept
        }
    }
    public let type: String = ProtocolTypes.didcommconnectionRequest.rawValue
    public let id: String
    public let from: DID
    public let to: DID
    public let thid: String?
    public let body: Body

    public init(inviteMessage: Message, from: DID) throws {
        guard let toDID = inviteMessage.from else { throw PrismAgentError.invitationIsInvalidError }
        let body = try JSONDecoder.didComm().decode(Body.self, from: inviteMessage.body)
        self.init(from: from, to: toDID, thid: inviteMessage.id, body: body)
    }

    public init(inviteMessage: OutOfBandInvitation, from: DID) throws {
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

    public init(fromMessage: Message) throws {
        guard
            fromMessage.piuri == ProtocolTypes.didcommconnectionRequest.rawValue,
            let from = fromMessage.from,
            let to = fromMessage.to
        else { throw PrismAgentError.invalidMessageType(
            type: fromMessage.piuri,
            shouldBe: ProtocolTypes.didcommconnectionRequest.rawValue)
        }
        self.init(
            from: from,
            to: to,
            thid: fromMessage.id,
            body: try JSONDecoder.didComm().decode(Body.self, from: fromMessage.body)
        )
    }

    public init(
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

    public func makeMessage() throws -> Message {
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
