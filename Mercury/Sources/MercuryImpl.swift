import DIDCommxSwift
import Domain
import Foundation

public struct MercuryImpl {
    let session: SessionManager
    let castor: Castor
    let didcomm: DidComm

    public init(
        session: URLSession = .shared,
        timeout: TimeInterval = 30,
        castor: Castor
    ) {
        self.session = SessionManager(session: session, timeout: timeout)
        self.castor = castor
        let didResolver = ExampleDidResolver(knownDids: [ALICE_DID_DOC, BOB_DID_DOC])
        let secretsResolver = ExampleSecretsResolver(knownSecrets: ALICE_SECRETS)
        self.didcomm = DidComm(
            didResolver: didResolver,
            secretResolver: secretsResolver
        )
    }
}

extension ExampleDidResolver: DidResolver {}
extension ExampleSecretsResolver: SecretsResolver {}
