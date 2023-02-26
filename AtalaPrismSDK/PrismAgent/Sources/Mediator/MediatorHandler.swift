import Domain

public protocol MediatorHandler {
    var mediatorDID: DID { get }
    var mediator: Mediator? { get }

    @discardableResult
    func bootRegisteredMediator() async throws -> Mediator?
    @discardableResult
    func achieveMediation(host: DID) async throws -> Mediator
    func updateKeyListWithDIDs(dids: [DID]) async throws
    func pickupUnreadMessages(limit: Int) async throws -> [(String, Message)]
    func registerMessagesAsRead(ids: [String]) async throws
}
