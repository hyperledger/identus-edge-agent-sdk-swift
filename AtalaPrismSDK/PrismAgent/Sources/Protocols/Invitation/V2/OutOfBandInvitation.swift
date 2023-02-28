import Core
import Domain
import Foundation

/**
 Represents an out-of-band invitation message in the DIDComm protocol.

 The `OutOfBandInvitation` struct represents an out-of-band invitation message in the DIDComm protocol.

 */
public struct OutOfBandInvitation: Decodable {

    /**
     Represents the body of the out-of-band invitation message.

     The `Body` struct represents the body of the out-of-band invitation message.

     */
    public struct Body: Decodable {
        public let goalCode: String?
        public let goal: String?
        public let accept: [String]?
    }

    // Properties of the out-of-band invitation message
    public let id: String
    public let type = ProtocolTypes.didcomminvitation.rawValue
    public let from: String
    public let body: Body

    /**
     Creates a new `OutOfBandInvitation` object.

     The `init` method creates a new `OutOfBandInvitation` object with the specified properties.

     - Parameters:
        - id: The ID of the out-of-band invitation message.
        - body: The body of the out-of-band invitation message.
        - from: The DID of the sender of the out-of-band invitation message.

     */
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

