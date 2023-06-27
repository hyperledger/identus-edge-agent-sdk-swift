import Domain
import Foundation

// https://github.com/hyperledger/aries-rfcs/tree/main/features/0453-issue-credential-v2#preview-credential
public struct CredentialPreview: Codable, Equatable {
    public struct Attribute: Codable, Equatable {
        public let name: String
        public let value: String
        public let mimeType: String?
        
        public init(name: String, value: String, mimeType: String?) {
            self.name = name
            self.value = value
            self.mimeType = mimeType
        }
    }

    public let type: String
    public let attributes: [Attribute]

    public init(attributes: [Attribute]) {
        self.type = ProtocolTypes.didcommCredentialPreview.rawValue
        self.attributes = attributes
    }
}

public struct CredentialFormat: Codable, Equatable {
//    know Format:
//     https://github.com/hyperledger/aries-rfcs/tree/main/features/0453-issue-credential-v2#propose-attachment-registry
//    - dif/credential-manifest@v1.0
//    - aries/ld-proof-vc-detail@v1.0
//    - hlindy/cred-filter@v2.0
//    
    public let attachId: String
    public let format: String
}
