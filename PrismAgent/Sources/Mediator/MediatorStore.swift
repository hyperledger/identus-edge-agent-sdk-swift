import Domain

public protocol MediatorStore {
    func storeMediator(mediator: Mediator) async throws
    func getAllMediators() async throws -> [Mediator]
}
