@testable import Domain
import Foundation
extension Message: Equatable {
    public static func == (lhs: Domain.Message, rhs: Domain.Message) -> Bool {
        lhs.id == rhs.id && lhs.piuri == rhs.piuri
    }
}
