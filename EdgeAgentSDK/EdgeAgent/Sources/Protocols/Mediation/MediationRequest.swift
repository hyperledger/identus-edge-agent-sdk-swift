import Domain
import Foundation

struct MediationRequest {
    let id: String
    let type = ProtocolTypes.didcommMediationRequest.rawValue
    let from: DID
    let to: DID

    init(
        id: String = UUID().uuidString,
        from: DID,
        to: DID
    ) {
        self.id = id
        self.from = from
        self.to = to
    }

    func makeMessage() -> Message {
        return Message(
            id: id,
            piuri: type,
            from: from,
            to: to,
            body: Data(),
            extraHeaders: ["return_route":"all"]
        )
    }
}
