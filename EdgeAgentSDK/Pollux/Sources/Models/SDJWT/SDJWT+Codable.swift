import Foundation

extension SDJWTCredential: Codable {
    enum CodingKeys: String, CodingKey {
        case sdjwtString
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(sdjwtString, forKey: .sdjwtString)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let sdjwtString = try container.decode(String.self, forKey: .sdjwtString)

        try self.init(sdjwtString: sdjwtString)
    }
}
