import Domain
@testable import EdgeAgent

let mockMediator = Mediator(
    hostDID: DID(method: "test", methodId: "test"),
    routingDID: DID(method: "test", methodId: "test"),
    mediatorDID: DID(method: "test", methodId: "test")
)

class MockMediatorHandler: MediatorHandler {
    let mediatorDID: DID
    let mediator: Mediator?
    var messages: [Message]

    init(
        mediatorDID: DID = .init(method: "test", methodId: "test"),
        mediator: Mediator? = mockMediator,
        messages: [Message] = []
    ) {
        self.mediatorDID = mediatorDID
        self.mediator = mediator
        self.messages = messages
    }

    func bootRegisteredMediator() async throws -> Mediator? {
        mediator
    }
    
    func achieveMediation(host: DID) async throws -> Mediator {
        mediator!
    }
    
    func updateKeyListWithDIDs(dids: [Domain.DID]) async throws {}
    
    func pickupUnreadMessages(limit: Int) async throws -> [(String, Domain.Message)] {
        messages.map { ($0.id, $0) }
    }
    
    func registerMessagesAsRead(ids: [String]) async throws {
        messages.removeAll { ids.contains($0.id) }
    }
}
