import Foundation
import PrismAgent
import Builders
import Combine
import Domain
import Pluto
import Core

class Sdk: Ability {
    private var sdk: PrismAgent? = nil
    
    static func use() -> Sdk {
        return Sdk()
    }
    
    func getSdk() -> PrismAgent {
        return sdk!
    }
    
    func initialize() async throws {
        let mediatorDID = try await getPrismMediatorDid()

        let apollo = ApolloBuilder().build()
        let castor = CastorBuilder(apollo: apollo).build()
        let pluto = PlutoBuilder(setup: .init(
            coreDataSetup: .init(
                modelPath: .storeName("PrismPluto"),
                storeType: .memory
            ),
            keychain: KeychainMock()
        )).build()
        let pollux = PolluxBuilder().build()
        let mercury = MercuryBuilder(
            castor: castor,
            secretsStream: createSecretsStream(
                keyRestoration: apollo,
                pluto: pluto,
                castor: castor
            )
        ).build()
        
        PrismAgent.setupLogging(logLevels: [
            .prismAgent: .warning
        ])
        
        sdk = PrismAgent(
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
        
        try await sdk!.start()
        sdk!.startFetchingMessages()
    }
    
    func teardown() async throws {
        sdk!.stopFetchingMessages()
        try await sdk!.stop()
    }
    
    private func getPrismMediatorDid() async throws -> DID {
        let url = URL(string: "http://localhost:8080/invitation")!
        let jsonData: [String: Any] = try await Api.get(from: url)
        let did = (jsonData["from"] as? String)!
        return try DID(string: did)
    }
    
    private func getRootsMediatorDid() async throws -> DID {
        let url = URL(string: "http://localhost:8000/oob_url")!
        let invitationUrl: String = try await Api.get(from: url)
        let base64data: String = String(invitationUrl.split(separator: "?_oob=").last!)
        let decodedData = Sdk.fromBase64(base64data)
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
    
    private func createSecretsStream(
        keyRestoration: KeyRestoration,
        pluto: Pluto,
        castor: Castor
    ) -> AnyPublisher<[Secret], Error> {
        pluto.getAllPeerDIDs()
            .first()
            .flatMap { array in
                Future {
                    try await array.asyncMap { did, privateKeys, _ in
                        let privateKeys = try await privateKeys.asyncMap {
                            try await keyRestoration.restorePrivateKey($0)
                        }
                        let secrets = try self.parsePrivateKeys(
                            did: did,
                            privateKeys: privateKeys,
                            castor: castor
                        )

                        return secrets
                    }
                }
            }
            .map {
                $0.compactMap {
                    $0
                }.flatMap {
                    $0
                } }
            .eraseToAnyPublisher()
    }
    
    private func parsePrivateKeys(
        did: DID,
        privateKeys: [PrivateKey],
        castor: Castor
    ) throws -> [Domain.Secret] {
        return try privateKeys
            .map { $0 as? (PrivateKey & ExportableKey) }
            .compactMap { $0 }
            .map { privateKey in
            let ecnumbasis = try castor.getEcnumbasis(did: did, publicKey: privateKey.publicKey())
            return (did, privateKey, ecnumbasis)
        }
        .map { did, privateKey, ecnumbasis in
            try parseToSecret(
                did: did,
                privateKey: privateKey,
                ecnumbasis: ecnumbasis
            )
        }
    }
    
    private func parseToSecret(did: DID, privateKey: PrivateKey & ExportableKey, ecnumbasis: String) throws -> Domain.Secret {
        let id = did.string + "#" + ecnumbasis
        let jwk = privateKey.jwk
        guard
            let dataJson = try? JSONEncoder().encode(jwk),
            let stringJson = String(data: dataJson, encoding: .utf8)
        else {
            throw CommonError.invalidCoding(message: "Could not encode privateKey.jwk")
        }
        return .init(
            id: id,
            type: .jsonWebKey2020,
            secretMaterial: .jwk(value: stringJson)
        )
    }

}
