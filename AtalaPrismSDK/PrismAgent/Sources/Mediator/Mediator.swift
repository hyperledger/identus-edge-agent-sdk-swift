import Domain

public protocol MediatorStore {
    func storeMediator(mediator: Mediator) async throws
    func getAllMediators() async throws -> [Mediator]
}

public struct Mediator {
    let hostDID: DID
    let routingDID: DID
    let mediatorDID: DID
}
