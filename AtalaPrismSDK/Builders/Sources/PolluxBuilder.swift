import Domain
import Pollux

public struct PolluxBuilder {
    let castor: Castor

    public init(castor: Castor) {
        self.castor = castor
    }

    public func build() -> Pollux {
        PolluxImpl(castor: castor)
    }
}
