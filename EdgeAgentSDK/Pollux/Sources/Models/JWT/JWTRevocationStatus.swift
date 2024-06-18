import Foundation

struct JWTRevocationStatus: Codable {
    enum CredentialStatusListType: String, Codable {
        case statusList2021Entry = "StatusList2021Entry"
    }

    enum CredentialStatusPurpose: String, Codable {
        case revocation
        case suspension
    }

    let id: String
    let type: String
    let statusPurpose: CredentialStatusPurpose
    let statusListIndex: Int
    let statusListCredential: String
}

struct JWTRevocationStatusListCredential: Codable {
    struct StatusListCredentialSubject: Codable {
        let type: String
        let statusPurpose: String
        let encodedList: String
    }
    let context: [String]
    let type: [String]
    let id: String
    let issuer: String
    let issuanceDate: String
    let credentialSubject: StatusListCredentialSubject
}
