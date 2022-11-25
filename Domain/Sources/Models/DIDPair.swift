public struct DIDPair: Equatable {
    public let holder: DID
    public let other: DID
    public let name: String?

    public init(holder: DID, other: DID, name: String?) {
        self.holder = holder
        self.other = other
        self.name = name
    }
}
