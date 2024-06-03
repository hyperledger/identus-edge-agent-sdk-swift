import Domain
import Foundation

extension SDJWTCredential: StorableCredential {
    var storingId: String {
        sdjwtString
    }
    
    var recoveryId: String {
        "sd-jwt+credential"
    }
    
    var credentialData: Data {
        (try? sdjwtString.tryToData()) ?? Data()
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
        nil
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
