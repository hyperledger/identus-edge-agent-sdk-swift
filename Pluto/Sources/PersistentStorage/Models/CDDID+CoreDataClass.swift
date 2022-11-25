import Domain
import CoreData
import Foundation

@objc(CDDID)
class CDDID: NSManagedObject {}

extension DID {
    init(from: CDDID) {
        self.init(
            schema: from.schema,
            method: from.method,
            methodId: from.methodId
        )
    }
}
