import Domain
import Foundation

extension JWTCredential: StorableCredential {
    var storingId: String {
        jwtString
    }
    
    var recoveryId: String {
        "jwt+credential"
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
        jwtVerifiableCredential.verifiableCredential.credentialSchema?.id
    }
    
    var queryValidUntil: Date? {
        jwtVerifiableCredential.exp
    }
    
    var queryRevoked: Bool? {
        nil
    }
    
    var queryAvailableClaims: [String] {
        claims.map(\.key)
    }
}
