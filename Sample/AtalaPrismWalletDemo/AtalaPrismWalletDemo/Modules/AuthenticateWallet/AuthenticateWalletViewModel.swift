import Foundation
import Domain
import Builders
import Authenticate
import UIKit

class AuthenticateWalletViewModelImpl: AuthenticateWalletViewModel {
    
    private let seedKey = "Seed"
    private let privateKeyKey = "PrivateKey"
    private let privateKeyCurveKey = "PrivateKeyCurve"
    private let didKey = "DID"
    private let storage = UserDefaults.standard
    private let castor: Castor
    private let apollo: Apollo
    private let authenticate: AuthenticateChallenged
    private var challengeObject: ChallengeObject? {
        didSet {
            challenge = challengeObject.map {
                Challenge(
                    challenger: $0.challengerName,
                    challenge: $0.challenge,
                    challengeAccepted: false
                )
            }
        }
    }

    @Published var did: String {
        didSet {
            storage.set(did, forKey: didKey)
        }
    }
    @Published var challenge: Challenge? = nil
    @Published var error: Error?
    
    init(did: String = "", challenge: Challenge? = nil) {
        if did.isEmpty {
            self.did = storage.string(forKey: didKey) ?? ""
        } else {
            self.did = did
        }
        self.challenge = challenge
        self.apollo = ApolloBuilder().build()
        self.castor = CastorBuilder(apollo: apollo).build()
        self.authenticate = AuthenticateChallenged(
            castor: castor,
            apollo: apollo,
            scheme: .init(scheme: "walletX", host: "challenge"),
            deepLinkPusher: UIApplication.shared
        )
    }
    
    func createPrismDID() {
        // Wallet logic side
        let seed = createOrGetSeed()
        let keyPair = apollo.createKeyPair(seed: seed, index: 0)
        setPrivateKey(privateKey: keyPair.privateKey)

        // Integration with Atala Prism side
        do {
            did = try authenticate.createPrismDIDForAuthenticate(publicKey: keyPair.publicKey).string
        } catch {
            self.error = error
        }
    }
    
    func createPeerDID() {
        // Wallet logic side
    }
    
    func didReceiveChallenge(url: URL) {
        do {
            self.challengeObject = try authenticate.receivedPrismChallenge(url: url)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func acceptChallenge() async {
        do {
            guard let challengeObject, let privateKey = getPrivateKey() else { return }
            let submitObject = try authenticate.acceptChallenge(challenge: challengeObject, privateKey: privateKey)
            try await authenticate.submitChallengeAnswer(submitedChallenge: submitObject)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func refuseChallenge() {
        challenge = nil
    }
    
    func reset() {
        did = ""
        storage.set(nil, forKey: seedKey)
        storage.set(nil, forKey: privateKeyKey)
        storage.set(nil, forKey: privateKeyCurveKey)
        
    }
    
    private func getPrivateKey() -> PrivateKey? {
        guard
            let data = storage.data(forKey: privateKeyKey),
            let curve = storage.string(forKey: privateKeyCurveKey)
        else { return nil }

        return PrivateKey(curve: curve, value: data)
    }

    private func setPrivateKey(privateKey: PrivateKey) {
        storage.set(privateKey.value, forKey: privateKeyKey)
        storage.set(privateKey.curve, forKey: privateKeyCurveKey)
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
        await self.open(url)
    }
}
