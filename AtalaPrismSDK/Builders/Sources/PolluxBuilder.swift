import Domain
import Pollux

public struct PolluxBuilder {
    let apollo: Apollo
    let castor: Castor

    public init(
        apollo: Apollo,
        castor: Castor
    ) {
        self.apollo = apollo
        self.castor = castor
    }

    public func build() -> Pollux {
        PolluxImpl(
            apollo: apollo,
            castor: castor
        )
    }
}
