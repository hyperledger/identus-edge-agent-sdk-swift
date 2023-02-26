import Castor
import Domain

public struct CastorBuilder {
    let apollo: Apollo

    public init(apollo: Apollo) {
        self.apollo = apollo
    }

    public func build() -> Castor {
        CastorImpl(apollo: apollo)
    }
}
