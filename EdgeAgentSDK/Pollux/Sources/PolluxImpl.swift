import Combine
import Domain

public struct PolluxImpl {
    let pluto: Pluto
    let castor: Castor
    public init(castor: Castor, pluto: Pluto) {
        self.pluto = pluto
        self.castor = castor
    }
}
