import Foundation
import Domain
import Builders
import Authenticate
import UIKit

class ContentViewModelImpl: ContentViewModel {
    private let apollo: Apollo
    private let castor: Castor
    private let authenticate: AuthenticateChallenger
    private let storage = UserDefaults.standard
    private let seedKey = "Seed"
    private let privateKeyKey = "PrivateKey"
    var did: String = ""
    var isLoggedIn: Bool = false

    init() {
        self.apollo = ApolloBuilder().build()
        self.castor = CastorBuilder(apollo: apollo).build()
        self.authenticate = .init(
            castor: castor,
            apollo: apollo,
            scheme: .init(
                scheme: "ChallengeApp",
                host: "submitChallenge"
            ),
            deepLinkPusher: UIApplication.shared
        )
    }
    
    func login(name: String) async {
        do {
            let keyPair = apollo.createKeyPair(seed: createOrGetSeed(), index: 0)
            let challenge = try authenticate.processChallengeForAuthenticate(
                did: try castor.parseDID(str: did),
                challengerName: name,
                challengerPublicKey: keyPair.publicKey,
                challenge: UUID().uuidString
            )

            try await authenticate.startAuthenticateWithPrism(challengeObject: challenge)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func verifyChallenge(url: URL) {
        Task {
            do {
                let submited = try authenticate.submitedPrismChallenge(url: url)
                let verification = try await authenticate.verifyChallenge(submitedChallengeResponse: submited)
                isLoggedIn = verification
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }

    private func getPrivateKey() -> Data? {
        storage.data(forKey: privateKeyKey)
    }

    private func createOrGetSeed() -> Seed {
        guard let seed = storage.data(forKey: seedKey) else {
            let (_, seed) = apollo.createRandomSeed()
            storage.set(seed.value, forKey: seedKey)
            return seed
        }
        return Seed(value: seed)
    }
}

extension UIApplication: DeepLinkPusher {
    public func openDeepLink(url: URL) async throws -> Bool {
        await open(url)
    }
}
