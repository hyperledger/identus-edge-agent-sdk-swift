import Foundation

public protocol StorableKey {
    var restorationIdentifier: String { get }
    var storableData: Data { get }
}

public extension Key {
    var isStorable: Bool { self is StorableKey }
    var storable: StorableKey? { self as? StorableKey }
}
