import Builders
import Combine
import Domain
import Foundation

public class PrismAgent {
    public enum State: String {
        case stoped
        case starting
        case running
        case stoping
    }

    public enum DIDType {
        case prism
        case peer
    }

    public enum InvitationType {
        public struct PrismOnboarding {
            public let from: String
            public let endpoint: URL
            public let ownDID: DID
        }

        case onboardingPrism(PrismOnboarding)
        case onboardingDIDComm(OutOfBandInvitation)
    }

    public private(set) var state = State.stoped

    private static let prismMediatorEndpoint = DID(method: "peer", methodId: "other")

    private let apollo: Apollo
    private let castor: Castor
    private let pluto: Pluto
    private let mercury: Mercury
    private let mediatorServiceEnpoint: DID

    private var connectionManager: ConnectionsManagerImpl
    private var cancellables = [AnyCancellable]()
    // Not a "stream"
    private var messagesStreamTask: Task<Void, Error>?

    public let seed: Seed

    public var mediatorRoutingDID: DID? {
        connectionManager.mediator?.routingDID
    }

    public init(
        apollo: Apollo,
        castor: Castor,
        pluto: Pluto,
        mercury: Mercury,
        seed: Seed? = nil,
        mediatorServiceEnpoint: DID? = nil
    ) {
        self.apollo = apollo
        self.castor = castor
        self.pluto = pluto
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

    public convenience init(seedData: Data? = nil, mediatorServiceEnpoint: DID? = nil) {
        let apollo = ApolloBuilder().build()
        let castor = CastorBuilder(apollo: apollo).build()
        let pluto = PlutoBuilder().build()
        let seed = seedData.map { Seed(value: $0) } ?? apollo.createRandomSeed().seed
        self.init(
            apollo: apollo,
            castor: castor,
            pluto: pluto,
            mercury: MercuryBuilder(
                apollo: apollo,
                castor: castor,
                pluto: pluto
            ).build(),
            seed: seed,
            mediatorServiceEnpoint: mediatorServiceEnpoint ?? Self.prismMediatorEndpoint
        )
    }

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
    }

    public func stop() async throws {
        guard state == .running else { return }
        state = .stoping
        cancellables.forEach { $0.cancel() }
        connectionManager.stopAllEvents()
        state = .stoped
    }

    public func signWith(did: DID, message: Data) async throws -> Signature {
        let seed = self.seed
        let apollo = self.apollo
        let pluto = self.pluto
        return try await withCheckedThrowingContinuation { continuation in
            pluto
                // First get DID info (KeyPathIndex in this case)
                .getPrismDIDInfo(did: did)
                .tryMap {
                    // if no register is found throw an error
                    guard let index = $0?.keyPairIndex else { throw PrismAgentError.cannotFindDIDKeyPairIndex }
                    // Re-Create the key pair to sign the message
                    let keyPair = apollo.createKeyPair(seed: seed, curve: .secp256k1(index: index))
                    return apollo.signMessage(privateKey: keyPair.privateKey, message: message)
                }
                .first()
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: {
                    continuation.resume(returning: $0)
                })
                .store(in: &self.cancellables)
        }
    }

    public func parseInvitation(str: String) async throws -> InvitationType {
        if let prismOnboarding = try? await parsePrismInvitation(str: str) {
            return .onboardingPrism(prismOnboarding)
        } else if let message = try? await parseOOBInvitation(url: str) {
            return .onboardingDIDComm(message)
        }
        throw PrismAgentError.unknownInvitationTypeError
    }

    public func parsePrismInvitation(str: String) async throws -> InvitationType.PrismOnboarding {
        let prismOnboarding = try PrismOnboardingInvitation(jsonString: str)
        guard
            let url = URL(string: prismOnboarding.body.onboardEndpoint)
        else { throw PrismAgentError.invalidURLError }

        let did = try await self.createNewPeerDID(
            services: [.init(
                id: "#didcomm-1",
                type: ["DIDCommMessaging"],
                serviceEndpoint:.init(uri: mediatorServiceEnpoint.string))
            ],
            updateMediator: true
        )

        return .init(
            from: prismOnboarding.body.from,
            endpoint: url,
            ownDID: did
        )
    }

    public func parseOOBInvitation(url: String) async throws -> OutOfBandInvitation {
        guard let url = URL(string: url) else { throw PrismAgentError.invalidURLError }
        return try await parseOOBInvitation(url: url)
    }

    public func parseOOBInvitation(url: URL) async throws -> OutOfBandInvitation {
        return try await DIDCommInvitationRunner(
            mercury: mercury,
            url: url
        ).run()
    }

    public func acceptDIDCommInvitation(invitation: OutOfBandInvitation) async throws {
        let ownDID = try await createNewPeerDID(
            services: [.init(
                id: "#didcomm-1",
                type: ["DIDCommMessaging"],
                serviceEndpoint:.init(uri: mediatorServiceEnpoint.string))
            ],
            updateMediator: true
        )
        let pair = try await DIDCommConnectionRunner(
            invitationMessage: invitation,
            ownDID: ownDID,
            connection: connectionManager
        ).run()
        try await connectionManager.addConnection(pair)
    }

    public func acceptPrismInvitation(invitation: InvitationType.PrismOnboarding) async throws {
        struct SendDID: Encodable {
            let did: String
        }
        var request = URLRequest(url: invitation.endpoint)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(SendDID(did: invitation.ownDID.string))
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        let response = try await URLSession.shared.data(for: request)
        guard
            let urlResponse = response.1 as? HTTPURLResponse,
            urlResponse.statusCode == 200
        else { throw PrismAgentError.failedToOnboardError }
    }

    public func createNewPrismDID(
        keyPathIndex: Int? = nil,
        alias: String? = nil,
        services: [DIDDocument.Service] = []
    ) async throws -> DID {
        let seed = self.seed
        let apollo = self.apollo
        let castor = self.castor
        let pluto = self.pluto

        return try await withCheckedThrowingContinuation { continuation in
            pluto
                // Retrieve the last keyPath index used
                .getPrismLastKeyPairIndex()
                .tryMap {
                    // If the user provided a key path index use it, if not use the last + 1
                    let index = keyPathIndex ?? ($0 + 1)
                    // Create the key pair
                    let keyPair = apollo.createKeyPair(seed: seed, curve: .secp256k1(index: index))
                    let newDID = try castor.createPrismDID(masterPublicKey: keyPair.publicKey, services: services)
                    return (newDID, index, alias)
                }
                .flatMap { did, index, alias in
                    // Store the did and its index path
                    return pluto
                        .storePrismDID(did: did, keyPairIndex: index, alias: alias)
                        .map { did }
                }
                .first()
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: {
                    continuation.resume(returning: $0)
                })
                .store(in: &self.cancellables)
        }
    }

    public func createNewPeerDID(
        services: [DIDDocument.Service] = [],
        updateMediator: Bool
    ) async throws -> DID {
        let apollo = self.apollo
        let castor = self.castor
        let pluto = self.pluto

        let keyAgreementKeyPair = apollo.createKeyPair(seed: seed, curve: .x25519)
        let authenticationKeyPair = apollo.createKeyPair(seed: seed, curve: .ed25519)

        let did = try castor.createPeerDID(
            keyAgreementKeyPair: keyAgreementKeyPair,
            authenticationKeyPair: authenticationKeyPair,
            services: services
        )

        if updateMediator {
            guard let mediator = connectionManager.mediator else {
                throw PrismAgentError.noMediatorAvailableError
            }
            let keyListUpdateMessage = try MediationKeysUpdateList(
                from: mediator.peerDID,
                to: mediator.mediatorDID,
                recipientDid: did
            ).makeMessage()

            try await mercury.sendMessage(msg: keyListUpdateMessage)
        }

        return try await withCheckedThrowingContinuation { continuation in
            pluto
                .storePeerDID(
                    did: did,
                    privateKeys: [
                        keyAgreementKeyPair.privateKey,
                        authenticationKeyPair.privateKey
                    ])
                .map { did }
                .first()
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: {
                    continuation.resume(returning: $0)
                })
                .store(in: &self.cancellables)
        }
    }

    public func startFetchingMessages() {
        // TODO: This needs to be better thought for sure it cannot be left like this
        let manager = connectionManager
        messagesStreamTask = Task {
            while true {
                _ = try await manager.awaitMessages()
                sleep(5)
            }
        }
    }

    public func stopFetchingMessages() {
        messagesStreamTask?.cancel()
    }

    public func handleMessagesEvents() -> AnyPublisher<Message, Error> {
        pluto.getAllMessages()
            .flatMap { $0.publisher }
            .eraseToAnyPublisher()
    }
}
