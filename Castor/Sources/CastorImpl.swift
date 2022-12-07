import Core
import Domain
import Foundation

public struct CastorImpl {
    let apollo: Apollo
    let resolvers: [DIDResolverDomain]

    public init(apollo: Apollo, resolvers: [DIDResolverDomain] = []) {
        self.apollo = apollo
        self.resolvers = resolvers + [
//            LongFormPrismDIDResolver(apollo: apollo),
            PeerDIDResolver()
        ]
    }

    func verifySignature(document: DIDDocument, signature: String, challenge: String) -> Bool {
        return false
    }
}
