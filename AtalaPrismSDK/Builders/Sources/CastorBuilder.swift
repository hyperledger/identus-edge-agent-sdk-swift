import Castor
import Domain

public struct CastorBuilder {
    let apollo: Apollo

    public init(apollo: Apollo) {
        self.apollo = apollo
    }

    public func build() -> [CastorPlugin] {
        [PeerDIDPlugin(apollo: apollo), PrismDIDPlugin(apollo: apollo)]
    }
}
