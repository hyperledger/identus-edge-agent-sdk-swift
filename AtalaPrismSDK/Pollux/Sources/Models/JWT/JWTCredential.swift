import Domain
import Foundation
import JSONWebSignature

public struct JWTCredential {
    let jwtString: String
    let jwtVerifiableCredential: JWTPayload

    public init(data: Data) throws {
        guard let jwtString = String(data: data, encoding: .utf8) else { throw PolluxError.invalidJWTString }
        var jwtParts = jwtString.components(separatedBy: ".")
        guard jwtParts.count == 3 else { throw PolluxError.invalidJWTString }
        jwtParts.removeFirst()
        guard
            let credentialString = jwtParts.first,
            let base64Data = Data(fromBase64URL: credentialString),
            let jsonString = String(data: base64Data, encoding: .utf8)
        else { throw PolluxError.invalidJWTString }

        guard let dataValue = jsonString.data(using: .utf8) else { throw PolluxError.invalidCredentialError }
        self.jwtString = jwtString
        self.jwtVerifiableCredential = try JSONDecoder().decode(JWTPayload.self, from: dataValue)
    }
}

extension JWTCredential: Codable {}

extension JWTCredential: Credential {
    public var id: String {
        jwtString
    }
    
    public var issuer: String {
        jwtVerifiableCredential.iss.string
    }
    
    public var subject: String? {
        jwtVerifiableCredential.sub
    }
    
    public var claims: [Claim] {
        guard
            let dic = jwtVerifiableCredential.verifiableCredential.credentialSubject.value as? [String: String]
        else {
            return []
        }
        return dic.map {
            Claim(key: $0, value: .string($1))
        }
    }
    
    public var properties: [String : Any] {
        var properties = [
            "nbf" : jwtVerifiableCredential.nbf,
            "jti" : jwtVerifiableCredential.jti,
            "type" : jwtVerifiableCredential.verifiableCredential.type,
            "aud" : jwtVerifiableCredential.aud,
            "id" : jwtString
        ] as [String : Any]
        
        jwtVerifiableCredential.exp.map { properties["exp"] = $0 }
        jwtVerifiableCredential.verifiableCredential.credentialSchema.map { properties["schema"] = $0.id }
        jwtVerifiableCredential.verifiableCredential.credentialStatus.map { properties["credentialStatus"] = $0.type }
        jwtVerifiableCredential.verifiableCredential.refreshService.map { properties["refreshService"] = $0.type }
        jwtVerifiableCredential.verifiableCredential.evidence.map { properties["evidence"] = $0.type }
        jwtVerifiableCredential.verifiableCredential.termsOfUse.map { properties["termsOfUse"] = $0.type }
        
        return properties
    }
    
    public var credentialType: String { "JWT" }
}

extension JWTCredential {
    func getJSON() throws -> Data {
        var jwtParts = jwtString.components(separatedBy: ".")
        jwtParts.removeFirst()
        guard
            let credentialString = jwtParts.first,
            let base64Data = Data(fromBase64URL: credentialString),
            let jsonString = String(data: base64Data, encoding: .utf8)
        else { throw PolluxError.invalidJWTString }

        guard let dataValue = jsonString.data(using: .utf8) else { throw PolluxError.invalidCredentialError }
        return dataValue
    }

    func getAlg() throws -> String {
        let jwtParts = jwtString.components(separatedBy: ".")
        guard
            let headerString = jwtParts.first,
            let base64Data = Data(fromBase64URL: headerString),
            let alg = try JSONDecoder.didComm().decode(DefaultJWSHeaderImpl.self, from: base64Data).algorithm?.rawValue
        else { throw PolluxError.couldNotFindCredentialAlgorithm }

        return alg
    }
}
