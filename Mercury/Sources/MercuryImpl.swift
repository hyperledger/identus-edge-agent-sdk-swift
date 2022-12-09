import DIDCommxSwift
import Domain
import Foundation

public struct MercuryImpl {
    let session: SessionManager
    let castor: Castor
    let apollo: Apollo
    let pluto: Pluto
    let didcomm: DidComm

    public init(
        session: URLSession = .shared,
        timeout: TimeInterval = 30,
        apollo: Apollo,
        castor: Castor,
        pluto: Pluto
    ) {
        self.session = SessionManager(session: session, timeout: timeout)
        self.castor = castor
        self.apollo = apollo
        self.pluto = pluto
        let didResolver = DIDCommDIDResolverWrapper(castor: castor)
        let secretsResolver = DIDCommSecretsResolverWrapper(
            apollo: apollo,
            pluto: pluto,
            castor: castor
        )
        self.didcomm = DidComm(
            didResolver: didResolver,
            secretResolver: secretsResolver
        )
    }
}

extension ExampleDidResolver: DidResolver {}
extension ExampleSecretsResolver: SecretsResolver {}
