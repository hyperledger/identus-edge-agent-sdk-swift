import Core
import Domain
import Foundation

/**
 A struct representing a connection request message in the DIDComm protocol.

 The ConnectionRequest struct defines properties and methods for encoding, decoding, and sending connection request messages in the DIDComm protocol.

 - Note: The ConnectionRequest struct is used to send connection request messages in the DIDComm protocol.

 */
public struct ConnectionRequest {

    // The body of the connection request message, which is the same as the body of the invitation message
    public struct Body: Codable {

        // The goal code of the connection request message
        public let goalCode: String?

        // The goal of the connection request message
        public let goal: String?

        // An array of strings representing the requested message types
        public let accept: [String]?

        /**
         Initializes a new instance of the Body struct with the specified parameters.

         - Parameter goalCode: The goal code of the connection request message.
         - Parameter goal: The goal of the connection request message.
         - Parameter accept: An array of strings representing the requested message types.

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

    // The type of the connection request message
    public let type: String = ProtocolTypes.didcommconnectionRequest.rawValue

    // The ID of the connection request message
    public let id: String

    // The DID of the sender of the connection request message
    public let from: DID

    // The DID of the recipient of the connection request message
    public let to: DID

    // The thread ID of the connection request message
    public let thid: String?

    // The body of the connection request message
    public let body: Body

    /**
     Initializes a new instance of the ConnectionRequest struct from the specified invitation message.

     - Parameter inviteMessage: The invitation message to use for initialization.
     - Parameter from: The DID of the sender of the connection request message.

     - Throws: An error if there was a problem decoding the invitation message.

     */
    public init(inviteMessage: Message, from: DID) throws {
        guard let toDID = inviteMessage.from else { throw EdgeAgentError.invitationIsInvalidError }
        let body = try JSONDecoder.didComm().decode(Body.self, from: inviteMessage.body)
        self.init(from: from, to: toDID, thid: inviteMessage.id, body: body)
    }

    /**
     Initializes a new instance of the ConnectionRequest struct from the specified out-of-band invitation.

     - Parameter inviteMessage: The out-of-band invitation to use for initialization.
     - Parameter from: The DID of the sender of the connection request message.

     - Throws: An error if there was a problem initializing the connection request.

     */
    public init(inviteMessage: OutOfBandInvitation, from: DID) throws {
        let toDID = try DID(string: inviteMessage.from)
        self.init(
            from: from,
            to: toDID,
            thid: inviteMessage.id,
            body: .init(
                goalCode: inviteMessage.body.goalCode,
                goal: inviteMessage.body.goal,
                accept: inviteMessage.body.accept
            )
        )
    }

    /**
     Initializes a new instance of the ConnectionRequest struct from the specified message.

     - Parameter fromMessage: The message to decode.

     - Throws: An error if there was a problem decoding the message.

     */
    public init(fromMessage: Message) throws {
        guard
            fromMessage.piuri == ProtocolTypes.didcommconnectionRequest.rawValue,
            let from = fromMessage.from,
            let to = fromMessage.to
        else { throw EdgeAgentError.invalidMessageType(
            type: fromMessage.piuri,
            shouldBe: [ProtocolTypes.didcommconnectionRequest.rawValue]
        ) }
        
        self.init(
            from: from,
            to: to,
            thid: fromMessage.id,
            body: try JSONDecoder.didComm().decode(Body.self, from: fromMessage.body)
        )
    }

    /**
     Initializes a new instance of the ConnectionRequest struct with the specified parameters.

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
    
    /**
     Creates a new `Message` object from the `ConnectionRequest`.

     The `makeMessage()` method creates a new `Message` object from the current `ConnectionRequest` object.

     - Returns: A new `Message` object that can be used to send the connection request.

     - Throws: An error if there was a problem encoding the body of the `ConnectionRequest` message.

     */
    public func makeMessage() throws -> Message {

        // Creates a new Message object with the properties of the ConnectionRequest object
        Message(
            id: id,
            piuri: type,
            from: from,
            to: to,
            body: try JSONEncoder.didComm().encode(self.body),
            thid: thid,
            direction: .sent
        )
    }
}
