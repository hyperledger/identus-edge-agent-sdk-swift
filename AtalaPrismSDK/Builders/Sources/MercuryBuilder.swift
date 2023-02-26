import Domain
import Foundation
import Mercury

public struct MercuryBuilder {
    let apollo: Apollo
    let castor: Castor
    let pluto: Pluto
    let session: URLSession
    let timeout: TimeInterval

    public init(
        apollo: Apollo,
        castor: Castor,
        pluto: Pluto,
        session: URLSession = .shared,
        timeout: TimeInterval = 30
    ) {
        self.apollo = apollo
        self.castor = castor
        self.pluto = pluto
        self.session = session
        self.timeout = timeout
    }

    public func build() -> Mercury {
        MercuryImpl(
            session: session,
            timeout: timeout,
            apollo: apollo,
            castor: castor,
            pluto: pluto
        )
    }
}
