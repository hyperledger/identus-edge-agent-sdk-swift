import Domain

/**
 A protocol representing a store for storing and retrieving mediators.

 The MediatorStore protocol defines methods for storing and retrieving mediators.

 - Note: The MediatorStore protocol is designed to be used in conjunction with the mediator routing feature of the DIDComm protocol.

 */
public protocol MediatorStore {

    /**
     Stores the specified mediator in the store.

     - Parameter mediator: The mediator to store.

     - Throws: An error if there was a problem storing the mediator.

     */
    func storeMediator(mediator: Mediator) async throws

    /**
     Retrieves all mediators from the store.

     - Returns: An array of mediators stored in the store.

     - Throws: An error if there was a problem retrieving the mediators from the store.

     */
    func getAllMediators() async throws -> [Mediator]
}

/**
 A struct representing a mediator.

 The Mediator struct contains properties for the mediator's host DID, routing DID, and mediator DID.

 - Note: The Mediator struct is designed to be used in conjunction with the mediator routing feature of the DIDComm protocol.

 */
public struct Mediator {

    // The DID of the entity that is hosting the mediator
    let hostDID: DID

    // The DID of the entity that is responsible for routing messages to and from the mediator
    let routingDID: DID

    // The DID of the mediator entity
    let mediatorDID: DID
}
