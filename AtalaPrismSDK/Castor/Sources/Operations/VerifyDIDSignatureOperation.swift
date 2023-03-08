import Core
import Domain
import Foundation

struct VerifyDIDSignatureOperation {
    let apollo: Apollo
    let document: DIDDocument
    let challenge: Data
    let signature: Data

    func compute() throws -> Bool {
        return try document.authenticate
            .compactMap { $0.publicKey }
            .contains {
                try apollo.verifySignature(
                    publicKey: $0,
                    challenge: challenge,
                    signature: Signature(value: signature)
                )
            }
    }
}
