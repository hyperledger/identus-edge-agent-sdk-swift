import Domain
import Foundation
import PrismAPI

extension Domain.PrivateKey {
    init(fromEC: ECPrivateKey) {
        self.init(curve: ECConfig().CURVE_NAME, value: fromEC.getEncoded().toData())
    }
}
