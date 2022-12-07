import Domain
import Foundation

struct JWKHelper {
    func fromJWK(material: VerificationMaterialAgreement) throws -> Data? {
        guard
            let jsonDic = try convertToDictionary(string: material.value),
            let crv = jsonDic["crv"],
            let xKey = jsonDic["x"],
            crv == "X25519"
        else { throw CastorError.invalidJWKKeysError }

        return Data(base64URLEncoded: xKey)
    }

    func fromJWK(material: VerificationMaterialAuthentication) throws -> Data? {
        guard
            let jsonDic = try convertToDictionary(string: material.value),
            let crv = jsonDic["crv"],
            let xKey = jsonDic["x"],
            crv == "Ed25519"
        else { throw CastorError.invalidJWKKeysError }

        return Data(base64URLEncoded: xKey)
    }

    func toJWK(publicKey: Data, material: VerificationMethodTypePeerDID) throws -> String? {
        let xKeyString = publicKey.base64UrlEncodedString()
        let crv: String
        switch material {
        case let agreement as VerificationMethodTypeAgreement where agreement == .jsonWebKey2020:
            crv = "X25519"
        case let authentication as VerificationMethodTypeAuthentication where authentication == .jsonWebKey2020:
            crv = "Ed25519"
        default:
            throw CastorError.invalidJWKKeysError
        }
        return try convertToJsonString(dic: [
            "kty" : "OKP",
            "crv" : crv,
            "x" : xKeyString
        ])
    }
}
