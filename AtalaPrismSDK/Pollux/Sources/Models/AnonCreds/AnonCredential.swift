import AnoncredsSwift
import Domain
import Foundation

struct AnonCredential {
    struct Attribute {
        let raw: String
        let encoded: String
    }
    
    struct Signature {
        struct PrimaryCredential {
            let m2: String
            let a: String
            let e: String
            let v: String
        }
        
        struct RevocationCredential {
            struct WitnessSignature {
                let sigmaI: String
                let uI: String
                let gI: String
            }
            let sigma: String
            let c: String
            let vrPrimePrime: String
            let witnessSignature: WitnessSignature
            let gI: String
            let i: Int
            let m2: String
        }
        
        let primaryCredential: PrimaryCredential
        let revocationCredential: RevocationCredential?
    }
    
    struct SignatureCorrectnessProof {
        let se: String
        let c: String
    }
    
    struct RevocationRegistry {
        let accum: String
    }
    
    struct Witness {
        let omega: String
    }
    
    let schemaId: String
    let credentialDefinitionId: String
    let values: [String: Attribute]
    let signature: Signature
    let signatureCorrectnessProof: SignatureCorrectnessProof
    let revocationRegistryId: String?
    let revocationRegistry: RevocationRegistry?
    let witness: Witness?
    
    func getAnoncred() throws -> AnoncredsSwift.Credential {
        let json = try JSONEncoder.didComm().encode(self)
        guard let jsonString = String(data: json, encoding: .utf8) else {
            throw UnknownError.somethingWentWrongError()
        }
        return try .init(jsonString: jsonString)
    }
}

extension AnonCredential.Attribute: Codable {}
extension AnonCredential.Signature.PrimaryCredential: Codable {
    enum CodingKeys: String, CodingKey {
        case m2 = "m_2"
        case a
        case e
        case v
    }
}
extension AnonCredential.Signature.RevocationCredential: Codable {
    enum CodingKeys: String, CodingKey {
        case sigma
        case c
        case vrPrimePrime = "vr_prime_prime"
        case witnessSignature = "witness_signature"
        case gI = "g_i"
        case i
        case m2 = "m2"
    }
}
extension AnonCredential.Signature.RevocationCredential.WitnessSignature: Codable {
    enum CodingKeys: String, CodingKey {
        case sigmaI = "sigma_i"
        case uI = "u_i"
        case gI = "g_i"
    }
}
extension AnonCredential.Signature: Codable {
    enum CodingKeys: String, CodingKey {
        case primaryCredential = "p_credential"
        case revocationCredential = "r_credential"
    }
}
extension AnonCredential.RevocationRegistry: Codable {}
extension AnonCredential.SignatureCorrectnessProof: Codable {}
extension AnonCredential.Witness: Codable {}
extension AnonCredential: Codable {
    enum CodingKeys: String, CodingKey {
        case schemaId = "schema_id"
        case credentialDefinitionId = "cred_def_id"
        case revocationRegistryId = "rev_reg_id"
        case values
        case signature
        case signatureCorrectnessProof = "signature_correctness_proof"
        case revocationRegistry = "rev_reg"
        case witness
    }
}

extension AnonCredential: Domain.Credential {
    var id: String {
        guard
            let jsonData = try? JSONEncoder().encode(self),
            let identifier = String(data: jsonData.sha256, encoding: .utf8)
        else {
            assert(true, "This should never happen")
            return ""
        }
        return identifier
    }
    
    var issuer: String {
        ""
    }
    
    var subject: String? {
        nil
    }
    
    var claims: [Domain.Claim] {
        values.map {
            .init(key: $0, value: .string($1.raw))
        }
    }
    
    var properties: [String : Any] {
        let properties = [
            "schemaId" : schemaId,
            "credentialDefinitionId" : credentialDefinitionId,
//            "signatureJson" : signatureJson,
//            "signatureCorrectnessProofJson" : signatureCorrectnessProofJson,
//            "witnessJson" : witnessJson
        ] as [String : Any]
        
//        revocationRegistryId.map { properties["revocationRegistryId"] = $0 }
//        revocationRegistryJson.map { properties["revocationRegistryJson"] = $0 }
        
        return properties
    }
}
