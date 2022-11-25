import Builders
import Combine
import Domain
import Foundation

public class PrismAgent {
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
        case onboardingDIDComm(Message)
    }

    // swiftlint:disable force_unwrapping
    private static let prismMediatorEndpoint = URL(string: "localhost:8080")!
    // swiftlint:enable force_unwrapping

    private let apollo: Apollo
    private let castor: Castor
    private let pluto: Pluto
    private let mercury: Mercury
    private let mediatorServiceEnpoint: URL

    private var running = false
    private var connectionManager: ConnectionsManager
    private var cancellables = [AnyCancellable]()

    public let seed: Seed

    public init(
        apollo: Apollo,
        castor: Castor,
        pluto: Pluto,
        mercury: Mercury,
        seed: Seed? = nil,
        mediatorServiceEnpoint: URL? = nil
    ) {
        self.apollo = apollo
        self.castor = castor
        self.pluto = pluto
        self.mercury = mercury
        self.seed = seed ?? apollo.createRandomSeed().seed
        self.mediatorServiceEnpoint = mediatorServiceEnpoint ?? Self.prismMediatorEndpoint
        self.connectionManager = ConnectionsManager(
            mercury: mercury,
            pluto: pluto,
            connections: []
        )
    }

    public convenience init(seedData: Data? = nil, mediatorServiceEnpoint: URL? = nil) {
        let apollo = ApolloBuilder().build()
        let castor = CastorBuilder(apollo: apollo).build()
        let seed = seedData.map { Seed(value: $0) } ?? apollo.createRandomSeed().seed
        self.init(
            apollo: apollo,
            castor: castor,
            pluto: PlutoBuilder().build(),
            mercury: MercuryBuilder(castor: castor).build(),
            seed: seed,
            mediatorServiceEnpoint: mediatorServiceEnpoint ?? Self.prismMediatorEndpoint
        )
    }

    public func createNewDID(
        type: DIDType,
        keyPathIndex: Int? = nil,
        alias: String? = nil,
        services: [DIDDocument.Service] = []
    ) async throws -> DID {
        let seed = self.seed
        let apollo = self.apollo
        let castor = self.castor
        let pluto = self.pluto
        // Pluto is based on combine (Probably going to add async/await versions so this is in pluto)
        return try await withCheckedThrowingContinuation { continuation in
            pluto
                // Retrieve the last keyPath index used
                .getLastKeyPairIndex()
                .tryMap {
                    // If the user provided a key path index use it, if not use the last + 1
                    let index = keyPathIndex ?? ($0 + 1)
                    // Create the key pair
                    let keyPair = apollo.createKeyPair(seed: seed, index: index)
                    let newDID: DID
                    switch type {
                    case .prism:
                        newDID = try castor.createPrismDID(masterPublicKey: keyPair.publicKey, services: services)
                    case .peer:
                        // For now we just have PRISM DID this will change for peerDID
                        newDID = try castor.createPrismDID(masterPublicKey: keyPair.publicKey, services: services)
                    }
                    return (newDID, index, alias)
                }
                .flatMap { did, index, alias in
                    // Store the did and its index path
                    return pluto
                        .storeDID(did: did, keyPairIndex: index, alias: alias)
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

    public func signWith(did: DID, message: Data) async throws -> Signature {
        let seed = self.seed
        let apollo = self.apollo
        let pluto = self.pluto
        return try await withCheckedThrowingContinuation { continuation in
            pluto
                // First get DID info (KeyPathIndex in this case)
                .getDIDInfo(did: did)
                .tryMap {
                    // if no register is found throw an error
                    guard let index = $0?.keyPairIndex else { throw PrismAgentError.cannotFindDIDKeyPairIndex }
                    // Re-Create the key pair to sign the message
                    let keyPair = apollo.createKeyPair(seed: seed, index: index)
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

        let did = try await self.createNewDID(
            type: .peer,
            alias: prismOnboarding.body.onboardEndpoint,
            services: [.init(
                id: "#didcomm-1",
                type: ["DIDCommMessaging"],
                service: mediatorServiceEnpoint.absoluteString)
            ]
        )

        return .init(
            from: prismOnboarding.body.from,
            endpoint: url,
            ownDID: did
        )
    }

    public func parseOOBInvitation(url: String) async throws -> Message {
        guard let url = URL(string: url) else { throw PrismAgentError.invalidURLError }
        return try await parseOOBInvitation(url: url)
    }

    public func parseOOBInvitation(url: URL) async throws -> Message {
        return try DIDCommInvitationRunner(
            mercury: mercury,
            url: url
        ).run()
    }

    public func acceptDIDCommInvitation(invitation: Message) async throws {
        guard let fromDID = invitation.from else { throw PrismAgentError.invitationHasNoFromDIDError }
        let ownDID = try await createNewDID(
            type: .peer,
            alias: "com.connection.to.\(fromDID.string)"
        )
        let connection = try await DIDCommConnectionRunner(
            mercury: mercury,
            invitationMessage: invitation,
            ownDID: ownDID,
            connectionMaker: { ownDID, otherDID, mercury in
                Connection(holderDID: ownDID, otherDID: otherDID, mercury: mercury)
            }
        ).run()
        connectionManager.addConnection(connection)
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
}
