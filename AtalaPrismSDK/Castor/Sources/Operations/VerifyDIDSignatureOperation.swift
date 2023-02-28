import Core
import Domain
import Foundation

struct VerifyDIDSignatureOperation {
    let apollo: Apollo
    let document: DIDDocument
    let challenge: Data
    let signature: Data

    func compute() -> Bool {
        return document.authenticate
            .compactMap { $0.publicKey }
            .contains {
                apollo.verifySignature(
                    publicKey: $0,
                    challenge: challenge,
                    signature: Signature(value: signature)
                )
            }
    }
}