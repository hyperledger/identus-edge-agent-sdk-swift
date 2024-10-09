import Castor
import Domain

public struct CastorBuilder {
    let apollo: Apollo & KeyRestoration

    public init(apollo: Apollo & KeyRestoration) {
        self.apollo = apollo
    }

    public func build() -> Castor {
        CastorImpl(apollo: apollo)
    }
}
