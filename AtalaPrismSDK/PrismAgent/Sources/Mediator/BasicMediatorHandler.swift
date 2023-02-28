import Domain
import Foundation

/**
 A class that provides an implementation of `MediatorHandler` using a Pluto instance and a Mercury instance.

 `BasicMediatorHandler` can be used to register, retrieve and update mediator information, achieve mediation, pick up unread messages, and register messages as read.
 */
public class BasicMediatorHandler: MediatorHandler {

    /**
     A struct that provides an implementation of `MediatorStore` using a `Pluto` instance.

     `PlutoMediatorStoreImpl` can be used to store and retrieve mediator information in the `Pluto` store.
     */
    public struct PlutoMediatorStoreImpl: MediatorStore {
        let pluto: Pluto

        public init(pluto: Pluto) {
            self.pluto = pluto
        }

        /**
         Fetches all the mediators from the `Pluto` store.

         - Returns: An array of `Mediator` objects.
         - Throws: An error if there was a problem fetching the mediators.
         */
        public func getAllMediators() async throws -> [Mediator] {
            try await pluto
                .getAllMediators()
                .map { $0.map { Mediator(
                    hostDID: $0.did,
                    routingDID: $0.routingDID,
                    mediatorDID: $0.routingDID
                )}}
                .first()
                .await()
        }

        /**
         Stores a mediator in the `Pluto` store.

         - Parameter mediator: The `Mediator` object to store.
         - Throws: An error if there was a problem storing the mediator.
         */
        public func storeMediator(mediator: Mediator) async throws {
            try await pluto
                .storeMediator(
                    peer: mediator.hostDID,
                    routingDID: mediator.routingDID,
                    mediatorDID: mediator.mediatorDID
                )
                .first()
                .await()
        }
    }

    public let mediatorDID: DID
    public private(set) var mediator: Mediator?

    private let mercury: Mercury
    private let mediatorStore: MediatorStore

    /**
     Initializes a new instance of `BasicMediatorHandler`.

     - Parameters:
        - mediatorDID: The DID of the mediator.
        - mercury: The `Mercury` instance to use for sending messages.
        - store: The `MediatorStore` instance to use for storing and retrieving mediator information.
     */
    public init(mediatorDID: DID, mercury: Mercury, store: MediatorStore) {
        self.mediatorDID = mediatorDID
        self.mercury = mercury
        self.mediatorStore = store
    }

    /**
     Initializes a new instance of `BasicMediatorHandler` with a pre-registered mediator.

     - Parameters:
        - mediator: The pre-registered `Mediator` object.
        - mercury: The `Mercury` instance to use for sending messages.
        - store: The `MediatorStore` instance to use for storing and retrieving mediator information.
     */
    public init(mediator: Mediator, mercury: Mercury, store: MediatorStore) {
        self.mediatorDID = mediator.mediatorDID
        self.mediator = mediator
        self.mercury = mercury
        self.mediatorStore = store
    }
    public func bootRegisteredMediator() async throws -> Mediator? {
        guard let mediator else {
            let mediator = try await mediatorStore.getAllMediators().first
            self.mediator = mediator
            return mediator
        }
        return mediator
    }

    public func achieveMediation(host: DID) async throws -> Mediator {
        guard let mediator = try await bootRegisteredMediator() else {
            do {
                guard let message: Message = try await mercury
                    .sendMessageParseMessage(msg: MediationRequest(
                        from: host,
                        to: mediatorDID
                    ).makeMessage())
                else { throw UnknownError.somethingWentWrongError(
                    customMessage: "Trying to achieve mediation returned empty data",
                    underlyingErrors: nil
                ) }
                let grantMessage = try MediationGrant(fromMessage: message)
                let routingDID = try DID(string: grantMessage.body.routingDid)

                let mediator = Mediator(
                    hostDID: host,
                    routingDID: routingDID,
                    mediatorDID: mediatorDID
                )

                try await mediatorStore.storeMediator(mediator: mediator)

                self.mediator = mediator
                return mediator
            } catch let error {
                throw PrismAgentError.mediationRequestFailedError(underlyingErrors: [error])
            }
        }

        return mediator
    }

    public func updateKeyListWithDIDs(dids: [DID]) async throws {
        guard let mediator else { throw PrismAgentError.noMediatorAvailableError }
        let keyListUpdateMessage = try MediationKeysUpdateList(
            from: mediator.hostDID,
            to: mediator.mediatorDID,
            recipientDids: dids
        ).makeMessage()
        try await mercury.sendMessage(msg: keyListUpdateMessage)
    }

    public func pickupUnreadMessages(limit: Int) async throws -> [(String, Message)] {
        guard let mediator else { throw PrismAgentError.noMediatorAvailableError }
        let request = try PickUpRequest(
            from: mediator.hostDID,
            to: mediator.mediatorDID,
            body: .init(
                limit: "10"
            )
        ).makeMessage()
        guard let message = try await mercury.sendMessageParseMessage(msg: request) else {
            return []
        }
        let parsedMessages = try await PickupRunner(message: message, mercury: mercury).run()
        return parsedMessages
    }

    public func registerMessagesAsRead(ids: [String]) async throws {
        guard let mediator else { throw PrismAgentError.noMediatorAvailableError }
        let message = try PickUpReceived(
            from: mediator.hostDID,
            to: mediator.mediatorDID,
            body: .init(messageIdList: ids)
        ).makeMessage()
        try await mercury.sendMessage(msg: message)
    }
}
