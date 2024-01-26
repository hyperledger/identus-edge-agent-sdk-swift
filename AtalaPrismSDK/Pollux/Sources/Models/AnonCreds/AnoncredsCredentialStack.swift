import Core
import Domain
import Foundation

struct AnoncredsCredentialStack: Codable {
    let schema: AnonCredentialSchema?
    let definition: AnonCredentialDefinition
    let credential: AnonCredential
}

extension AnoncredsCredentialStack: Domain.Credential {
    var id: String {
        guard
            let jsonData = try? JSONEncoder.didComm().encode(credential)
        else {
            assert(false, "This should never happen")
            return ""
        }
        return jsonData.sha256.hex
    }
    
    var issuer: String {
        definition.issuerId ?? ""
    }
    
    var subject: String? {
        nil
    }
    
    var claims: [Domain.Claim] {
        credential.values.map {
            .init(key: $0, value: .string($1.raw))
        }
    }
    
    var properties: [String : Any] {
        var properties = [
            "schemaId" : credential.schemaId,
            "credentialDefinitionId" : credential.credentialDefinitionId,
        ] as [String : Any]
        
        (try? JSONEncoder.didComm().encode(definition)).map { properties["credentialDefinition"] = $0 }
        (try? JSONEncoder.didComm().encode(schema))
            .map { properties["schema"] = $0 }
        (try? JSONEncoder.didComm().encode(credential.signature)).map { properties["signature"] = $0 }
        (try? JSONEncoder.didComm().encode(credential.signatureCorrectnessProof)).map { properties["signatureCorrectnessProof"] = $0 }
        (try? JSONEncoder.didComm().encode(credential.witness)).map { properties["witness"] = $0 }
        
        return properties
    }
    
    var credentialType: String { "anoncreds" }
}
