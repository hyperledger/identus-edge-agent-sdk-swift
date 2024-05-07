import Domain
import Foundation

extension AnoncredsCredentialStack: StorableCredential {
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
        credential.schemaId
    }
    
    var queryValidUntil: Date? {
        nil
    }
    
    var queryRevoked: Bool? {
        nil
    }
    
    var queryAvailableClaims: [String] {
        claims.map(\.key)
    }
}
