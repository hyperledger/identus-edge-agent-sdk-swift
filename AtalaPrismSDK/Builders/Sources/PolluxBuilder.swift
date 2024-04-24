import Domain
import Pollux

public struct PolluxBuilder {
    private let pluto: Pluto
    private let castor: Castor

    public init(pluto: Pluto, castor: Castor) {
        self.pluto = pluto
        self.castor = castor
    }

    public func build() -> Pollux {
        PolluxImpl(castor: castor, pluto: pluto)
    }
}
