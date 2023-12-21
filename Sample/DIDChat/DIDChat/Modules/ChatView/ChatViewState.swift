import Foundation

struct ChatViewState {
    struct Message: Identifiable, Hashable {
        struct AgentReceived: Hashable {
            let title: String
            let messageId: String
            let needsResponse: Bool
        }

        struct AgentResponse: Hashable {
            let title: String
        }

        var id: Date { date }
        let date: Date
        let text: String
        let sent: Bool
        let attachedImage: Data?
        let agentReceived: AgentReceived?
        let agentResponse: AgentResponse?

        static func == (lhs: Message, rhs: Message) -> Bool {
            lhs.date == rhs.date 
            && lhs.text == rhs.text
            && lhs.sent == rhs.sent
            && lhs.agentReceived == rhs.agentReceived
            && lhs.agentResponse == rhs.agentResponse
        }
    }
}
