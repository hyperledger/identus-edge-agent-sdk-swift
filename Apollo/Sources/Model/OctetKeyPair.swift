import Core
import Domain
import Foundation

struct OctetKeyPair {
    struct PublicJson: Codable {
        enum CodingKeys: String, CodingKey {
            case kty
            case kid
            case crv
            case publicKey = "x"
        }

        let kty = "OKP"
        let kid: String
        let crv: String
        let publicKey: String

        init(kid: String, crv: String, publicKey: String) {
            self.kid = kid
            self.crv = crv
            self.publicKey = publicKey
        }
    }

    struct PrivateJson: Codable {
        enum CodingKeys: String, CodingKey {
            case kty
            case kid
            case crv
            case publicKey = "x"
            case privateKey = "d"
        }

        let kty = "OKP"
        let kid: String
        let crv: String
        let privateKey: String
        let publicKey: String

        init(kid: String, crv: String, privateKey: String, publicKey: String) {
            self.kid = kid
            self.crv = crv
            self.privateKey = privateKey
            self.publicKey = publicKey
        }
    }

    let kty = "OKP"
    let kid: String
    let crv: String
    let privateKey: String
    let publicKey: String

    init(id: String, from: KeyPair) throws {
        self.init(
            kid: id,
            crv: from.curve.name,
            privateKey: from.privateKey.value.base64UrlEncodedString(),
            publicKey: from.publicKey.value.base64UrlEncodedString()
        )
    }

    init(kid: String, crv: String, privateKey: String, publicKey: String) {
        self.kid = kid
        self.crv = crv
        self.privateKey = privateKey
        self.publicKey = publicKey
    }

    var publicJson: String? {
        let publicJson = PublicJson(
            kid: kid,
            crv: crv,
            publicKey: publicKey
        )
        guard let dataJson = try? JSONEncoder().encode(publicJson) else {
            return nil
        }
        return String(data: dataJson, encoding: .utf8)
    }
    var privateJson: String? {
        let privateJson = PrivateJson(
            kid: kid,
            crv: crv,
            privateKey: privateKey,
            publicKey: publicKey
        )
        guard let dataJson = try? JSONEncoder().encode(privateJson) else {
            return nil
        }
        return String(data: dataJson, encoding: .utf8)
    }
}
