import Domain
import Pollux

public struct PolluxBuilder {

    public init() {}

    public func build() -> Pollux {
        PolluxImpl()
    }
}
