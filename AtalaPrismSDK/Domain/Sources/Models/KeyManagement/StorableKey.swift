import Foundation

public enum SecurityLevel {
    case high
    case low
}

public protocol StorableKey {
    var securityLevel: SecurityLevel { get }
    var restorationIdentifier: String { get }
    var storableData: Data { get }
}

public extension Key {
    var isStorable: Bool { self is StorableKey }
    var storable: StorableKey? { self as? StorableKey }
}
