import Foundation

public struct Session {
    public let uuid: UUID
    public let seed: Seed

    public init(uuid: UUID = UUID(), seed: Seed) {
        self.uuid = uuid
        self.seed = seed
    }
}
