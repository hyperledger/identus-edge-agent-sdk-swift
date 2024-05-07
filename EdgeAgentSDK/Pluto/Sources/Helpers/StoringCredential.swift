import Domain
import Foundation

struct StoringCredential: StorableCredential {
    let storingId: String
    let recoveryId: String
    let credentialData: Data
    let queryIssuer: String?
    let querySubject: String?
    let queryCredentialCreated: Date?
    let queryCredentialUpdated: Date?
    let queryCredentialSchema: String?
    let queryValidUntil: Date?
    let queryRevoked: Bool?
    let queryAvailableClaims: [String]
}
