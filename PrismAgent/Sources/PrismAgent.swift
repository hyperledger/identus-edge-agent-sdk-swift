import Builders
import Combine
import Core
import Domain
import Foundation

/// PrismAgent class is responsible for handling the connection to other agents in the network using
/// a provided Mediator Service Endpoint and seed data.
public class PrismAgent {
    /// Enumeration representing the current state of the agent.
    public enum State: String {
        case stoped
        case starting
        case running
        case stoping
    }

    /// Represents the seed data used to create a unique DID.
    public let seed: Seed

    /// Represents the current state of the agent.
    public private(set) var state = State.stoped

    // TODO: This is to be deleted
    public private(set) var requestedPresentations: CurrentValueSubject<
        [(RequestPresentation, Bool)], Never
    > = .init([])

    /// The mediator routing DID if one is currently registered.
    public var mediatorRoutingDID: DID? {
        connectionManager.mediator?.routingDID
    }

    static let prismMediatorEndpoint = DID(method: "peer", methodId: "other")

    let logger = PrismLogger(category: .prismAgent)
    let apollo: Apollo
    let castor: Castor
    let pluto: Pluto
    let pollux: Pollux
    let mercury: Mercury
    let mediatorServiceEnpoint: DID

    var connectionManager: ConnectionsManagerImpl
    var cancellables = [AnyCancellable]()
    // Not a "stream"
    var messagesStreamTask: Task<Void, Error>?

    /// Initializes a PrismAgent with the given dependency objects and seed data.
    ///
    /// - Parameters:
    ///   - apollo: An instance of Apollo.
    ///   - castor: An instance of Castor.
    ///   - pluto: An instance of Pluto.
    ///   - pollux: An instance of Pollux.
    ///   - mercury: An instance of Mercury.
    ///   - seed: A unique seed used to generate the unique DID.
    ///   - mediatorServiceEnpoint: The endpoint of the Mediator service to use.
    public init(
        apollo: Apollo,
        castor: Castor,
        pluto: Pluto,
        pollux: Pollux,
        mercury: Mercury,
        seed: Seed? = nil,
        mediatorServiceEnpoint: DID? = nil
    ) {
        self.apollo = apollo
        self.castor = castor
        self.pluto = pluto
        self.pollux = pollux
        self.mercury = mercury
        self.seed = seed ?? apollo.createRandomSeed().seed
        self.mediatorServiceEnpoint = mediatorServiceEnpoint ?? Self.prismMediatorEndpoint
        self.connectionManager = ConnectionsManagerImpl(
            castor: castor,
            mercury: mercury,
            pluto: pluto,
            pairings: []
        )
    }

    /**
      Convenience initializer for `PrismAgent` that allows for optional initialization of seed data and mediator service endpoint.

      - Parameters:
        - seedData: Optional seed data for creating a new seed. If not provided, a random seed will be generated.
        - mediatorServiceEnpoint: Optional DID representing the service endpoint of the mediator. If not provided, the default Prism mediator endpoint will be used.
    */
    public convenience init(seedData: Data? = nil, mediatorServiceEnpoint: DID? = nil) {
        let apollo = ApolloBuilder().build()
        let castor = CastorBuilder(apollo: apollo).build()
        let pluto = PlutoBuilder().build()
        let pollux = PolluxBuilder(castor: castor).build()
        let seed = seedData.map { Seed(value: $0) } ?? apollo.createRandomSeed().seed
        self.init(
            apollo: apollo,
            castor: castor,
            pluto: pluto,
            pollux: pollux,
            mercury: MercuryBuilder(
                apollo: apollo,
                castor: castor,
                pluto: pluto
            ).build(),
            seed: seed,
            mediatorServiceEnpoint: mediatorServiceEnpoint ?? Self.prismMediatorEndpoint
        )
    }

    /**
     Start the PrismAgent and Mediator services

     - Throws: PrismAgentError.noMediatorAvailableError if no mediator is available,
     as well as any error thrown by `createNewPeerDID` and `connectionManager.registerMediator`
    */
    public func start() async throws {
            guard state == .stoped else { return }
            state = .starting
            do {
                try await connectionManager.startMediator()
            } catch PrismAgentError.noMediatorAvailableError {
                let hostDID = try await createNewPeerDID(
                    services: [.init(
                        id: "#didcomm-1",
                        type: ["DIDCommMessaging"],
                        serviceEndpoint:.init(uri: mediatorServiceEnpoint.string))
                    ],
                    updateMediator: false
                )
                try await connectionManager.registerMediator(
                    hostDID: hostDID,
                    mediatorDID: mediatorServiceEnpoint
                )
            }
            state = .running
            logger.info(message: "Mediation Achieved", metadata: [
                .publicMetadata(key: "Routing DID", value: mediatorRoutingDID?.string ?? "")
            ])
        }

    /**
      This function is used to stop the PrismAgent.
      The function sets the state of PrismAgent to .stoping.
      All ongoing events that was created by the PrismAgent are stopped.
      After all the events are stopped the state of the PrismAgent is set to .stoped.

      - Throws: If the current state is not running throws error.
      */
     public func stop() async throws {
         guard state == .running else { return }
         state = .stoping
         cancellables.forEach { $0.cancel() }
         connectionManager.stopAllEvents()
         state = .stoped
     }

    // TODO: This is to be deleted in the future. For now it helps with proof of request logic
    public func presentCredentialProof(
        request: RequestPresentation,
        credential: VerifiableCredential
    ) async throws {
        guard let jwtBase64 = credential.id.data(using: .utf8)?.base64UrlEncodedString() else {
            throw PrismAgentError.invalidRequestPresentationMessageError
        }
        let presentation = Presentation(
            body: .init(goalCode: request.body.goalCode, comment: request.body.comment),
            attachments: [try .build(
                payload: AttachmentBase64(base64: jwtBase64),
                mediaType: "prism/jwt"
            )],
            thid: request.id,
            from: request.to,
            to: request.from
        )
        _ = try await connectionManager.sendMessage(presentation.makeMessage())
    }

    // TODO: This is to be deleted in the future. For now it helps with issue credentials logic
    public func issueCredentialProtocol() {
        startFetchingMessages()
        Task {
            do {
                for try await offer in handleReceivedMessagesEvents()
                    .drop(while: { (try? OfferCredential(fromMessage: $0)) != nil })
                    .values
                {
                    if let issueProtocol = try? IssueCredentialProtocol(offer, connector: connectionManager) {
                        try? await issueProtocol.nextStage()
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension DID {
    func getMethodIdKeyAgreement() -> String {
        var str = methodId.components(separatedBy: ".")[1]
        str.removeFirst()
        return str
    }
}
