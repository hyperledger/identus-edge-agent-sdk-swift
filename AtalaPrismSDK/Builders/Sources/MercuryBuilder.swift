import Combine
import Domain
import Foundation
import Mercury

public struct MercuryBuilder {
    let castor: Castor
    let secretsStream: AnyPublisher<[Domain.Secret], Error>
    let session: URLSession
    let timeout: TimeInterval

    public init(
        castor: Castor,
        secretsStream: AnyPublisher<[Domain.Secret], Error>,
        session: URLSession = .shared,
        timeout: TimeInterval = 30
    ) {
        self.castor = castor
        self.secretsStream = secretsStream
        self.session = session
        self.timeout = timeout
    }

    public func build() -> Mercury {
        MercuryImpl(
            session: session,
            timeout: timeout,
            secretsStream: secretsStream,
            castor: castor
        )
    }
}
