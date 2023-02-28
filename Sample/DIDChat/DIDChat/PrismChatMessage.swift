import Domain
import Foundation

private let CHAT_MESSAGE_TYPE = "https://atalaprism.io/chat/message/1.0/send"

struct PrismChatMessage {
    let id: String
    let type = CHAT_MESSAGE_TYPE
    let from: DID
    let to: DID
    let date: Date
    let text: String

    init(
        id: String = UUID().uuidString,
        from: DID,
        to: DID,
        text: String,
        date: Date = Date()
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.text = text
        self.date = date
    }

    init?(fromMessage: Message) {
        guard
            fromMessage.piuri == CHAT_MESSAGE_TYPE,
            let from = fromMessage.from,
            let to = fromMessage.to
        else {
            return nil
        }
        self.id = fromMessage.id
        self.from = from
        self.to = to
        self.text = String(data: fromMessage.body, encoding: .utf8) ?? ""
        self.date = fromMessage.createdTime
    }

    func makeMessage() -> Message {
        return Message(
            id: id,
            piuri: type,
            from: from,
            to: to,
            body: text.data(using: .utf8)!,
            createdTime: date
        )
    }
}
