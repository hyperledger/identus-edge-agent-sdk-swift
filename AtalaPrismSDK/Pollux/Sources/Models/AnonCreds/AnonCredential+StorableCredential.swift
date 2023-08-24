import Domain
import Foundation

extension AnonCredential: StorableCredential {
    var storingId: String {
        id
    }
    
    var recoveryId: String {
        "anon+credential"
    }
    
    var credentialData: Data {
        (try? JSONEncoder().encode(self)) ?? Data()
    }
    
    var queryIssuer: String? {
        issuer
    }
    
    var querySubject: String? {
        subject
    }
    
    var queryCredentialCreated: Date? {
        nil
    }
    
    var queryCredentialUpdated: Date? {
        nil
    }
    
    var queryCredentialSchema: String? {
        schemaId
    }
    
    var queryValidUntil: Date? {
        nil
    }
    
    var queryRevoked: Bool? {
        nil
//        revocationRegistryId != nil
    }
    
    var queryAvailableClaims: [String] {
        claims.map(\.key)
    }
}
