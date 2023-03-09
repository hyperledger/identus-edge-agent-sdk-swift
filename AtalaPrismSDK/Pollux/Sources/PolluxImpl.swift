import Domain

public struct PolluxImpl {
    let apollo: Apollo
    let castor: Castor

    public init(apollo: Apollo, castor: Castor) {
        self.apollo = apollo
        self.castor = castor
    }
}
