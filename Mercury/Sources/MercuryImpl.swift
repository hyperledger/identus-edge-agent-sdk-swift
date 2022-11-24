import Domain
import Foundation

public struct MercuryImpl {
    let session: SessionManager
    let castor: Castor

    public init(
        session: URLSession = .shared,
        timeout: TimeInterval = 30,
        castor: Castor
    ) {
        self.session = SessionManager(session: session, timeout: timeout)
        self.castor = castor
    }
}
