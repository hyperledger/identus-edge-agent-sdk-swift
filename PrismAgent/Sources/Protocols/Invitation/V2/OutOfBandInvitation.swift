import Core
import Domain
import Foundation

public struct OutOfBandInvitation: Decodable {
    public struct Body: Decodable {
        public let goalCode: String?
        public let goal: String?
        public let accept: [String]?
    }

    public let id: String
    public let type = ProtocolTypes.didcomminvitation.rawValue
    public let from: String
    public let body: Body

    init(
        id: String = UUID().uuidString,
        body: Body,
        from: DID
    ) {
        self.id = id
        self.body = body
        self.from = from.string
    }
}
