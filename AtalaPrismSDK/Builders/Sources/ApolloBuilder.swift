import Apollo
import Domain

public struct ApolloBuilder {
    public init() {}

    public func build() -> Apollo {
        ApolloImpl()
    }
}
