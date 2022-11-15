import Core
import Domain
import Foundation

public struct AuthenticateChallenged {
    let castor: Castor
    let apollo: Apollo
    let scheme: AuthenticateDeepLink
    let deepLinkPusher: DeepLinkPusher

    public init(
        castor: Castor,
        apollo: Apollo,
        scheme: AuthenticateDeepLink,
        deepLinkPusher: DeepLinkPusher
    ) {
        self.castor = castor
        self.apollo = apollo
        self.scheme = scheme
        self.deepLinkPusher = deepLinkPusher
    }

    public func createPrismDIDForAuthenticate(publicKey: PublicKey) throws -> DID {
        try castor.createPrismDID(
            masterPublicKey: publicKey,
            services: [.init(
                id: "deeplink",
                type: ["deeplink"],
                service: scheme.scheme + "://" + scheme.host
            )]
        )
    }

    public func receivedPrismChallenge(url: URL) throws -> ChallengeObject {
        guard
            url.scheme == scheme.scheme,
            url.host == scheme.host,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { throw AuthenticateError.urlNotAuthenticateServiceError }

        return try ChallengeObject(fromQueryItems: components.queryItems ?? [])
    }

    public func acceptChallenge(
        challenge: ChallengeObject,
        privateKey: PrivateKey
    ) throws -> SubmitedChallengeObject {
        let signature = try apollo.signMessage(privateKey: privateKey, message: challenge.challenge)
        return .init(
            challengeObject: challenge,
            response: .accept(signature: Base64Utils().encode(signature.value))
        )
    }

    public func refuseChallenge(challenge: ChallengeObject) throws -> SubmitedChallengeObject {
        .init(challengeObject: challenge, response: .refuse)
    }

    public func submitChallengeAnswer(submitedChallenge: SubmitedChallengeObject) async throws {
        let did = try castor.parseDID(str: submitedChallenge.challengeObject.challengerDID)
        let didDocument = try castor.resolveDID(did: did)

        guard let service = didDocument.services
            .first(where: { $0.type.contains(where: { $0 == "deeplink" }) })?
            .service
        else { throw AuthenticateError.cannotFindDeepLinkServiceError }

        guard
            var components = URLComponents(string: service)
        else { throw AuthenticateError.invalidDeepLinkError }

        components.queryItems = submitedChallenge.queryItems

        guard
            let url = components.url
        else { throw AuthenticateError.invalidDeepLinkError }

        guard try await deepLinkPusher.openDeepLink(url: url) else {
            throw AuthenticateError.deepLinkNotAvailableError
        }
    }
}
