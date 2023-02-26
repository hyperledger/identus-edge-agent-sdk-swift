import Domain
import Foundation

struct LongFormPrismDID {
    private let prismMethodId: PrismDIDMethodId
    let did: DID
    let stateHash: String
    let encodedState: String

    init(did: DID) throws {
        self.did = did
        let methodId = try PrismDIDMethodId(string: did.methodId)

        guard
            methodId.sections.count == 2,
            let stateHash = methodId.sections.first,
            let encodedState = methodId.sections.last
        else { throw CastorError.invalidLongFormDID }

        prismMethodId = methodId
        self.stateHash = stateHash
        self.encodedState = encodedState
    }
}
