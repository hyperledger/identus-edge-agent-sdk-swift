import Core
import Domain
import Foundation

public struct ConnectionAccept {
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
    public let type: String = ProtocolTypes.didcommconnectionResponse.rawValue
    public let id: String
    public let from: DID
    public let to: DID
    public let thid: String?
    public let body: Body

    public init(fromMessage: Message) throws {
        guard
            fromMessage.piuri == ProtocolTypes.didcommconnectionResponse.rawValue,
            let from = fromMessage.from,
            let to = fromMessage.to
        else { throw PrismAgentError.invalidMessageType(
            type: fromMessage.piuri,
            shouldBe: ProtocolTypes.didcommconnectionResponse.rawValue
        ) }
        self.init(
            from: from,
            to: to,
            thid: fromMessage.thid,
            body: try JSONDecoder.didComm().decode(Body.self, from: fromMessage.body)
        )
    }

    public init(fromRequest: ConnectionRequest) {
        self.init(
            from: fromRequest.to,
            to: fromRequest.from,
            thid: fromRequest.id,
            body: .init(
                goalCode: fromRequest.body.goalCode,
                goal: fromRequest.body.goal,
                accept: fromRequest.body.accept
            )
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
