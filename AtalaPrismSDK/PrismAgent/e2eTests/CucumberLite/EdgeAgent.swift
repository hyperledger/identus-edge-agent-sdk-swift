import Foundation
import PrismAgent
import Builders
import Combine
import Domain
import Pluto

class EdgeAgent {
//    init() async throws {
//        let mediatorDID = try DID(string: "did:peer:2.Ez6LSms555YhFthn1WV8ciDBpZm86hK9tp83WojJUmxPGk1hZ.Vz6MkmdBjMyB4TS5UbbQw54szm8yvMMf1ftGV2sQVYAxaeWhE.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwczovL21lZGlhdG9yLnJvb3RzaWQuY2xvdWQiLCJhIjpbImRpZGNvbW0vdjIiXX0")
//        let prismAgent = PrismAgent(seedData: nil, mediatorDID: mediatorDID)
//        try await prismAgent.start()
//    }
    
    init() async throws {
        let mediatorDID = try DID(string: "did:peer:2.Ez6LShwwgh61j1s7pev4Yxpg2tpx3TVM7m1Na8cdM9b3hV2b1.Vz6MkvTPiJf5E4hof5EaKTpkFmetJ1ALCHty6A71Sm4o5Xby4.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwOi8vbG9jYWxob3N0OjgwMDAiLCJhIjpbImRpZGNvbW0vdjIiXX0")
//
//        let mediatorDID = try DID(string: "did:peer:2.Ez6LSms555YhFthn1WV8ciDBpZm86hK9tp83WojJUmxPGk1hZ.Vz6MkmdBjMyB4TS5UbbQw54szm8yvMMf1ftGV2sQVYAxaeWhE.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwczovL21lZGlhdG9yLnJvb3RzaWQuY2xvdWQiLCJhIjpbImRpZGNvbW0vdjIiXX0")

        let apollo = ApolloBuilder().build()
        let castor = CastorBuilder(apollo: apollo).build()
        let pluto = PlutoBuilder(setup: .init(
            coreDataSetup: .init(
                modelPath: .storeName("PrismPluto"),
                storeType: .memory
            )
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
        
        let agent = PrismAgent(
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
        
        try await agent.start()
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
                            try await keyRestoration.restorePrivateKey(
                                identifier: $0.restorationIdentifier,
                                data: $0.storableData
                            )
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
