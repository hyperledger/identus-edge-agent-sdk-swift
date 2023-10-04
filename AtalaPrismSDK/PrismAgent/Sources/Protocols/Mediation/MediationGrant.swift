import Domain
import Foundation

struct MediationGrant {
    struct Body: Codable {
        let routingDid: String
    }

    let id: String
    let type = ProtocolTypes.didcommMediationGrant.rawValue
    let body: Body

    init(
        id: String = UUID().uuidString,
        body: Body
    ) {
        self.id = id
        self.body = body
    }

    init(fromMessage: Message) throws {
        guard
            fromMessage.piuri == ProtocolTypes.didcommMediationGrant.rawValue
        else { throw PrismAgentError.invalidMessageType(
            type: fromMessage.piuri,
            shouldBe: [ProtocolTypes.didcommMediationGrant.rawValue]
        ) }
        self.init(
            id: fromMessage.id,
            body: try JSONDecoder.didComm().decode(Body.self, from: fromMessage.body)
        )
    }
}
