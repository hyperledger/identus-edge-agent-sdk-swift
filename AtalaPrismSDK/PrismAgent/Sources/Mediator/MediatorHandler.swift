import Domain

/**
 A protocol representing a mediator handler for handling mediator routing in the DIDComm protocol.

 The MediatorHandler protocol defines methods and properties for booting registered mediators, achieving mediation, updating key lists, picking up unread messages, and registering messages as read.

 - Note: The MediatorHandler protocol is designed to facilitate mediator routing in the DIDComm protocol.

 */
public protocol MediatorHandler {

    // The DID of the mediator associated with the mediator handler
    var mediatorDID: DID { get }

    // The active mediator associated with the mediator handler
    var mediator: Mediator? { get }

    /**
     Boots the registered mediator associated with the mediator handler.

     - Returns: The mediator that was booted.

     - Throws: An error if there was a problem booting the mediator.

     - Note: The @discardableResult attribute is used to suppress the warning generated by unused return values when this method is called.

     */
    @discardableResult
    func bootRegisteredMediator() async throws -> Mediator?

    /**
     Achieves mediation with the mediatorDID with the specified host DID as a user.

     - Parameter host: The DID of the entity to mediate with.

     - Returns: The mediator associated with the achieved mediation.

     - Throws: An error if there was a problem achieving mediation.

     */
    @discardableResult
    func achieveMediation(host: DID) async throws -> Mediator

    /**
     Updates the key list with the specified DIDs.

     - Parameter dids: An array of DIDs to add to the key list.

     - Throws: An error if there was a problem updating the key list.

     */
    func updateKeyListWithDIDs(dids: [DID]) async throws

    /**
     Picks up the specified number of unread messages.

     - Parameter limit: The maximum number of messages to pick up.

     - Returns: An array of tuples containing the message ID and the message itself.

     - Throws: An error if there was a problem picking up the messages.

     */
    func pickupUnreadMessages(limit: Int) async throws -> [(String, Message)]

    /**
     Registers the specified message IDs as read.

     - Parameter ids: An array of message IDs to register as read.

     - Throws: An error if there was a problem registering the messages as read.

     */
    func registerMessagesAsRead(ids: [String]) async throws
}
