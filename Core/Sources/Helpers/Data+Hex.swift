import Foundation

public extension Data {
    var hex: String {
        return self.reduce("") { $0 + String(format: "%02x", $1) }
    }
}
