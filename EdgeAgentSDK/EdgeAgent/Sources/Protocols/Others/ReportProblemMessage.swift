import Core
import Domain
import Foundation

public struct ReportProblemMessage {

    public struct Body: Codable {
        public let code: String
        public let comment: String?
        public let args: [String]?
        public let escalateTo: String?

        init(code: String, comment: String?, args: [String]?, escalateTo: String?) {
            self.code = code
            self.comment = comment
            self.args = args
            self.escalateTo = escalateTo
        }
    }

    public let id: String
    public let type = ProtocolTypes.didcommReportProblem.rawValue
    public let from: DID
    public let to: DID
    public let date: Date
    public let body: Body

    public init(
        id: String = UUID().uuidString,
        from: DID,
        to: DID,
        body: Body,
        date: Date = Date()
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.body = body
        self.date = date
    }

    public init?(fromMessage: Message) throws {
        guard
            fromMessage.piuri == ProtocolTypes.didcommReportProblem.rawValue,
            let from = fromMessage.from,
            let to = fromMessage.to
        else {
            return nil
        }
        self.id = fromMessage.id
        self.from = from
        self.to = to
        self.body = try JSONDecoder.didComm().decode(Body.self, from: fromMessage.body)
        self.date = fromMessage.createdTime
    }

    public func makeMessage() throws -> Message {
        return Message(
            id: id,
            piuri: type,
            from: from,
            to: to,
            body: try JSONEncoder.didComm().encode(body),
            createdTime: date,
            direction: .sent
        )
    }
}
