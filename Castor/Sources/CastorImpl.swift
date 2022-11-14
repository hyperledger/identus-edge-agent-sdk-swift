import Core
import Domain
import Foundation

public struct CastorImpl {
    let apollo: Apollo
    let resolvers: [DIDResolver]

    public init(apollo: Apollo, resolvers: [DIDResolver] = []) {
        self.apollo = apollo
        self.resolvers = resolvers + [LongFormPrismDIDResolver(apollo: apollo)]
    }

    func verifySignature(document: DIDDocument, signature: String, challenge: String) -> Bool {
        return false
    }
}
