/// Represents a pair of DIDs, typically used for secure communication or delegation of capabilities or services.
public struct DIDPair: Equatable {
    /// The holder DID.
    public let holder: DID

    /// The other DID in the pair.
    public let other: DID

    /// An optional name for the pair.
    public let name: String?

    public init(holder: DID, other: DID, name: String?) {
        self.holder = holder
        self.other = other
        self.name = name
    }
}
