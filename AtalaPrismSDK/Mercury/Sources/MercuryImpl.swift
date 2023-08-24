import Core
import DIDCommxSwift
import Domain
import Foundation

public struct MercuryImpl {
    let session: SessionManager
    let castor: Castor
    let apollo: Apollo
    let pluto: Pluto
    let logger: PrismLogger

    public init(
        session: URLSession = .shared,
        timeout: TimeInterval = 999,
        apollo: Apollo,
        castor: Castor,
        pluto: Pluto
    ) {
        let logger = PrismLogger(category: .mercury)
        self.logger = logger
        self.session = SessionManager(session: session, timeout: timeout)
        self.castor = castor
        self.apollo = apollo
        self.pluto = pluto
    }

    func getDidcomm() -> DidComm {
        let didResolver = DIDCommDIDResolverWrapper(castor: castor, logger: logger)
        let secretsResolver = DIDCommSecretsResolverWrapper(
            apollo: apollo,
            pluto: pluto,
            castor: castor,
            logger: logger
        )
        return DidComm(
            didResolver: didResolver,
            secretResolver: secretsResolver
        )
    }
}
