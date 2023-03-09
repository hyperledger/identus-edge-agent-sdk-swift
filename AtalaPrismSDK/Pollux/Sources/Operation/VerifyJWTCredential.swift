import CryptoKit
import Domain
import Foundation
import SwiftJWT

struct VerifyJWTCredential {
    let apollo: Apollo
    let castor: Castor
    let jwtString: String
    private let separatedJWTComponents: [String]
    private var headersComponent: String { separatedJWTComponents[0] }
    private var credentialComponent: String { separatedJWTComponents[1] }
    private var signatureComponent: String { separatedJWTComponents[2] }

    init(apollo: Apollo, castor: Castor, jwtString: String) throws {
        self.apollo = apollo
        self.castor = castor
        self.jwtString = jwtString
        self.separatedJWTComponents = jwtString.components(separatedBy: ".")
        guard
            self.separatedJWTComponents.count == 3
        else { throw PolluxError.invalidJWTString }
    }

    func compute() async throws -> Bool {
        let document = try await getDIDDocument()
        let pemKeys = try getAuthenticationPublicKeyPem(document: document)
        var result = false
        try pemKeys.forEach {
            guard
                !result,
                let pemData = $0.data(using: .utf8)
            else { return }
            let verifier = JWTVerifier.es256k(publicKey: pemData)
            let decoder = JWTDecoder(jwtVerifier: verifier)
            do {
                _ = try decoder.decode(JWT<ClaimsStandardJWT>.self, fromString: jwtString)
                result = true
            } catch let error as JWTError {
                switch error {
                case .invalidUTF8Data, .invalidJWTString, .invalidPrivateKey, .missingPEMHeaders:
                    throw error
                default:
                    break
                }
            }
        }
        return result
    }

    private func getDIDDocument() async throws -> DIDDocument {
        let did = try getJWTCredential().makeVerifiableCredential().issuer
        let document = try await castor.resolveDID(did: did)
        return document
    }

    private func getJWTCredential() throws -> JWTCredential {
        guard
            let base64Data = Data(fromBase64URL: credentialComponent),
            let jsonString = String(data: base64Data, encoding: .utf8)
        else { throw PolluxError.invalidJWTString }

        guard
            let dataValue = jsonString.data(using: .utf8)
        else { throw PolluxError.invalidCredentialError }
        return try JWTCredential(
            id: jwtString,
            fromJson: dataValue,
            decoder: JSONDecoder()
        )
    }

    private func getAuthenticationPublicKeyPem(document: DIDDocument) throws -> [String] {
        return document.authenticate
            .map { $0.publicKey.flatMap { keyDataToPEMString($0) } }
            .compactMap { $0 }
    }
}

public func keyDataToPEMString(_ keyData: PublicKey) -> String? {
    let keyBase64 = keyData.value.base64EncodedString()
    let pemString = """
    -----BEGIN PUBLIC KEY-----
    \(keyBase64)
    -----END PUBLIC KEY-----
    """
    return pemString
}
