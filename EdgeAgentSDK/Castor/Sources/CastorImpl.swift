import Core
import Domain
import Foundation

public struct CastorImpl {
    let apollo: Apollo & KeyRestoration
    let resolvers: [DIDResolverDomain]
    let logger: SDKLogger

    public init(apollo: Apollo & KeyRestoration, resolvers: [DIDResolverDomain] = []) {
        self.logger = SDKLogger(category: .castor)
        self.apollo = apollo
        self.resolvers = resolvers + [
            LongFormPrismDIDResolver(apollo: apollo, logger: logger),
            PeerDIDResolver()
        ]
    }

    func verifySignature(document: DIDDocument, signature: String, challenge: String) -> Bool {
        return false
    }
}
