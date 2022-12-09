import Domain
import Foundation
import PrismAPI

extension Domain.PrivateKey {
    init(curve: KeyCurve, fromEC: ECPrivateKey) {
        self.init(curve: curve, value: fromEC.getEncoded().toData())
    }
}
