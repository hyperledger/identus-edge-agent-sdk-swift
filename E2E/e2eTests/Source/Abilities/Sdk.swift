import Foundation
import EdgeAgent
import Builders
import Combine
import Domain
import Pluto
import Core

class Sdk: Ability {
    typealias AbilityInstanceType = Client
    let actor: Actor
    let abilityName: String = "Swift SDK"
    private var client: Client? = nil

    required init(_ actor: Actor) {
        self.actor = actor
    }
    
    func instance() -> AbilityInstanceType {
        return client!
    }
    
    func setUp(_ actor: Actor) async throws {
        client = try await Client()
        try await client!.initialize()
    }
    
    func tearDown() async throws {
        try await client?.tearDown()
    }
    
    class Client {
        var credentialOfferStack: [Message] = []
        var issueCredentialStack: [Message] = []
        var proofOfRequestStack: [Message] = []
        var receivedMessages: [String] = []
        var cancellables = Set<AnyCancellable>()
        
        let edgeAgent: EdgeAgent

        init() async throws {
            let mediatorDID = try await Client.getPrismMediatorDid()
//            let mediatorDID = try await Client.getRootsMediatorDid()
            
            let apollo = ApolloBuilder().build()
            let castor = CastorBuilder(apollo: apollo).build()
            let pluto = PlutoBuilder(setup: .init(
                coreDataSetup: .init(
                    modelPath: .storeName("PrismPluto"),
                    storeType: .memory
                ),
                keychain: KeychainMock()
            )).build()
            let pollux = PolluxBuilder(pluto: pluto, castor: castor).build()
            let mercury = MercuryBuilder(
                castor: castor,
                secretsStream: Client.createSecretsStream(
                    keyRestoration: apollo,
                    pluto: pluto,
                    castor: castor
                )
            ).build()
            
            EdgeAgent.setupLogging(logLevels: [
                .edgeAgent: .info
            ])
            
            edgeAgent = EdgeAgent(
                apollo: apollo,
                castor: castor,
                pluto: pluto,
                pollux: pollux,
                mercury: mercury,
                mediationHandler: BasicMediatorHandler(
                    mediatorDID: mediatorDID,
                    mercury: mercury,
                    store: BasicMediatorHandler.PlutoMediatorStoreImpl(pluto: pluto)
                )
            )
        }
        
        func initialize() async throws {
            try await edgeAgent.start()
            
            edgeAgent.handleReceivedMessagesEvents()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            print("Publisher completed successfully.")
                        case .failure(let error):
                            print("Publisher failed with error: \(error)")
                        }
                    },
                    receiveValue: { message in
                        if (self.receivedMessages.contains(message.id)) {
                            return
                        }
                        self.receivedMessages.append(message.id)
                        switch(message.piuri) {
                        case ProtocolTypes.didcommOfferCredential3_0.rawValue:
                            self.credentialOfferStack.append(message)
                        case ProtocolTypes.didcommIssueCredential3_0.rawValue:
                            self.issueCredentialStack.append(message)
                        case ProtocolTypes.didcommRequestPresentation.rawValue:
                            self.proofOfRequestStack.append(message)
                        default:
                            break
                        }
                    }
                )
                .store(in: &cancellables)
            
            edgeAgent.startFetchingMessages()
        }
        
        func tearDown() async throws {
            edgeAgent.stopFetchingMessages()
            try await edgeAgent.stop()
        }
        
        static private func getPrismMediatorDid() async throws -> DID {
            let url = URL(string: Config.mediatorOobUrl)!
            let jsonData: [String: Any] = try await Api.get(from: url)
            let did = (jsonData["from"] as? String)!
            return try DID(string: did)
        }
        
        static private func getRootsMediatorDid() async throws -> DID {
            let url = URL(string: Config.mediatorOobUrl)!
            let invitationUrl: String = try await Api.get(from: url)
            let base64data: String = String(invitationUrl.split(separator: "?_oob=").last!)
            let decodedData = Data(base64Encoded: base64data)!
            let json = try (JSONSerialization.jsonObject(with: decodedData, options: []) as? [String: Any])!
            let from = (json["from"] as? String)!
            return try DID(string: from)
        }
        
        private static func fromBase64(_ encoded: String) -> Data {
            var encoded = encoded;
            let remainder = encoded.count % 4
            if remainder > 0 {
                encoded = encoded.padding(
                    toLength: encoded.count + 4 - remainder,
                    withPad: "=", startingAt: 0);
            }
            return Data(base64Encoded: encoded)!
    //        return String(data: data, encoding: .utf8)!
        }
        
        static private func createSecretsStream(
            keyRestoration: KeyRestoration,
            pluto: Pluto,
            castor: Castor
        ) -> AnyPublisher<[Secret], Error> {
            pluto.getAllKeys()
                .first()
                .flatMap { keys in
                    Future {
                        let privateKeys = await keys.asyncMap {
                            try? await keyRestoration.restorePrivateKey($0)
                        }.compactMap { $0 }
                        return try parsePrivateKeys(
                            privateKeys: privateKeys,
                            castor: castor
                        )
                    }
                }
                .eraseToAnyPublisher()
        }
        
        static private func parsePrivateKeys(
            privateKeys: [PrivateKey],
            castor: Castor
        ) throws -> [Domain.Secret] {
            return try privateKeys
                .map { $0 as? (PrivateKey & ExportableKey & StorableKey) }
                .compactMap { $0 }
                .map { privateKey in
                    return privateKey
            }
            .map { privateKey in
                try parseToSecret(
                    privateKey: privateKey,
                    identifier: privateKey.identifier
                )
            }
        }
        
        static private func parseToSecret(
            privateKey: PrivateKey & ExportableKey,
            identifier: String
        ) throws -> Domain.Secret {
            let jwk = privateKey.jwk
            guard
                let dataJson = try? JSONEncoder().encode(jwk),
                let stringJson = String(data: dataJson, encoding: .utf8)
            else {
                throw CommonError.invalidCoding(message: "Could not encode privateKey.jwk")
            }
            return .init(
                id: identifier,
                type: .jsonWebKey2020,
                secretMaterial: .jwk(value: stringJson)
            )
        }
    }

}
