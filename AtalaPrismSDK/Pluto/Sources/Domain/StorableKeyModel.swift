import Domain
import Foundation

struct StorableKeyModel: StorableKey {
    let restorationIdentifier: String
    let storableData: Data
    let index: Int?
}
