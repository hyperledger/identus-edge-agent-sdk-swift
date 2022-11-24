import Domain
import Foundation
import Mercury

public struct MercuryBuilder {
    let castor: Castor
    let session: URLSession
    let timeout: TimeInterval

    public init(
        castor: Castor,
        session: URLSession = .shared,
        timeout: TimeInterval = 30
    ) {
        self.castor = castor
        self.session = session
        self.timeout = timeout
    }

    public func build() -> Mercury {
        MercuryImpl(session: session, timeout: timeout, castor: castor)
    }
}
