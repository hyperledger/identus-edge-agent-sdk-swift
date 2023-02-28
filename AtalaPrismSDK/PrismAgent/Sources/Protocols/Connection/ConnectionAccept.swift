import Core
import Domain
import Foundation

/**
 A struct representing a connection acceptance message in the DIDComm protocol.

 The ConnectionAccept struct defines properties and methods for encoding, decoding, and sending connection acceptance messages in the DIDComm protocol.

 - Note: The ConnectionAccept struct is used to send connection acceptance messages in the DIDComm protocol.

 */
public struct ConnectionAccept {

    // The body of the connection acceptance message, which is the same as the body of the invitation message
    public struct Body: Codable {

        // The goal code of the connection acceptance message
        public let goalCode: String?

        // The goal of the connection acceptance message
        public let goal: String?

        // An array of strings representing the accepted message types
        public let accept: [String]?

        /**
         Initializes a new instance of the Body struct with the specified parameters.

         - Parameter goalCode: The goal code of the connection acceptance message.
         - Parameter goal: The goal of the connection acceptance message.
         - Parameter accept: An array of strings representing the accepted message types.

         */
        public init(
            goalCode: String? = nil,
            goal: String? = nil,
            accept: [String]? = nil
        ) {
            self.goalCode = goalCode
            self.goal = goal
            self.accept = accept
        }
    }

    // The type of the connection acceptance message
    public let type: String = ProtocolTypes.didcommconnectionResponse.rawValue

    // The ID of the connection acceptance message
    public let id: String

    // The DID of the sender of the connection acceptance message
    public let from: DID

    // The DID of the recipient of the connection acceptance message
    public let to: DID

    // The thread ID of the connection acceptance message
    public let thid: String?

    // The body of the connection acceptance message
    public let body: Body

    /**
     Initializes a new instance of the ConnectionAccept struct from the specified message.

     - Parameter fromMessage: The message to decode.

     - Throws: An error if there was a problem decoding the message.

     */
    public init(fromMessage: Message) throws {
        guard
            fromMessage.piuri == ProtocolTypes.didcommconnectionResponse.rawValue,
            let from = fromMessage.from,
            let to = fromMessage.to
        else {
            throw PrismAgentError.invalidMessageType(
                type: fromMessage.piuri,
                shouldBe: ProtocolTypes.didcommconnectionResponse.rawValue
            )
        }

        self.init(
            from: from,
            to: to,
            thid: fromMessage.thid,
            body: try JSONDecoder.didComm().decode(Body.self, from: fromMessage.body)
        )
    }

    /**
     Initializes a new instance of the ConnectionAccept struct from the specified request.

     - Parameter fromRequest: The request to use for initialization.

     */
    public init(fromRequest: ConnectionRequest) {
        self.init(
            from: fromRequest.to,
            to: fromRequest.from,
            thid: fromRequest.id,
            body: .init(
                goalCode: fromRequest.body.goalCode,
                goal: fromRequest.body.goal,
                accept: fromRequest.body.accept
            )
        )
    }

    /**
     Initializes a new instance of the ConnectionAccept struct with the specified parameters.

     - Parameter id: The ID of the connection acceptance message.
     - Parameter from: The DID of the sender of the connection acceptance message.
     - Parameter to: The DID of the recipient of the connection acceptance message.
     - Parameter thid: The thread ID of the connection acceptance message.
     - Parameter body: The body of the connection acceptance message.

     */
    public init(
        id: String = UUID().uuidString,
        from: DID,
        to: DID,
        thid: String?,
        body: Body
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.thid = thid
        self.body = body
    }

    
    public func makeMessage() throws -> Message {
        Message(
            id: id,
            piuri: type,
            from: from,
            to: to,
            body: try JSONEncoder.didComm().encode(self.body),
            thid: thid
        )
    }
}
