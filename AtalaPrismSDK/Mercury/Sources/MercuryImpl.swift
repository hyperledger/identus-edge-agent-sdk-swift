import Combine
import Core
import DIDCommxSwift
import Domain
import Foundation

public struct MercuryImpl {
    let session: SessionManager
    let secretsStream: AnyPublisher<[Domain.Secret], Error>
    let castor: Castor
    let logger: PrismLogger

    public init(
        session: URLSession = .shared,
        timeout: TimeInterval = 999,
        secretsStream: AnyPublisher<[Domain.Secret], Error>,
        castor: Castor
    ) {
        let logger = PrismLogger(category: .mercury)
        self.logger = logger
        self.session = SessionManager(session: session, timeout: timeout)
        self.secretsStream = secretsStream
        self.castor = castor
    }

    func getDidcomm() -> DidComm {
        let didResolver = DIDCommDIDResolverWrapper(castor: castor, logger: logger)
        let secretsResolver = DIDCommSecretsResolverWrapper(
            secretsStream: secretsStream,
            castor: castor,
            logger: logger
        )
        return DidComm(
            didResolver: didResolver,
            secretResolver: secretsResolver
        )
    }
}
