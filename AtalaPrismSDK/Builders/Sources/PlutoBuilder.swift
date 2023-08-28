import Domain
import Pluto

public struct PlutoBuilder {
    let setup: PlutoImpl.PlutoSetup

    public init(setup: PlutoImpl.PlutoSetup = .init()) {
        self.setup = setup
    }

    public func build() -> Pluto {
        PlutoImpl(setup: setup)
    }
}
