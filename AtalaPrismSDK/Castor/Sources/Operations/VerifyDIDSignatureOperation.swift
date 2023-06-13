import Core
import Domain
import Foundation

struct VerifyDIDSignatureOperation {
    let apollo: Apollo
    let document: DIDDocument
    let challenge: Data
    let signature: Data

    func compute() async throws -> Bool {
        try await document.authenticate
            .asyncMap { verificationMethod -> PublicKey in
                try await verificationMethodToPublicKey(method: verificationMethod)
            }
            .compactMap { $0 }
            .asyncContains {
                try await $0.verify(data: challenge, signature: signature)
            }
    }

    private func verificationMethodToPublicKey(method: DIDDocument.VerificationMethod) async throws -> PublicKey {
        guard let multibaseData = method.publicKeyMultibase else {
            throw CastorError.cannotRetrievePublicKeyFromDocument
        }
        return try await apollo.createPrivateKey(
            parameters: [
                KeyProperties.type.rawValue: "EC",
                KeyProperties.rawKey.rawValue: multibaseData,
                KeyProperties.curve.rawValue: KnownKeyCurves.secp256k1.rawValue
            ]).publicKey()
    }
}

private extension Sequence {
    func asyncContains(
        _ transform: (Element) async throws -> Bool
    ) async rethrows -> Bool {
        for element in self {
            if try await transform(element) {
                return true
            }
        }

        return false
    }
}

