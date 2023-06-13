import Domain
import Pluto

public struct PlutoBuilder {
    let setup: PlutoImpl.PlutoSetup
    let keyRestoration: KeyRestoration

    public init(setup: PlutoImpl.PlutoSetup = .init(), keyRestoration: KeyRestoration) {
        self.setup = setup
        self.keyRestoration = keyRestoration
    }

    public func build() -> Pluto {
        PlutoImpl(setup: setup, keyRestoration: keyRestoration)
    }
}
