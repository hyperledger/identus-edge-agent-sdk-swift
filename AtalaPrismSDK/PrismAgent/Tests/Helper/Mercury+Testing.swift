import Domain
import Foundation

class MercuryStub: Mercury {
    var throwSendMessageError: Error?
    var throwUnpackError: Error?
    var throwPackageError: Error?
    var sendMessageDataReturn: Data?
    var sendMessageReturn: Message?

    func packMessage(msg: Domain.Message) async throws -> String {
        guard throwPackageError == nil else { throw throwPackageError! }
        let jsonStr = try JSONEncoder().encode(msg).base64EncodedString()
        return jsonStr
    }

    func unpackMessage(msg: String) async throws -> Domain.Message {
        guard throwUnpackError == nil else { throw throwUnpackError! }
        let message = try JSONDecoder().decode(Message.self, from: Data(base64Encoded: msg)!)
        return message
    }

    func sendMessage(_ msg: Domain.Message) async throws -> Data? {
        guard throwSendMessageError == nil else { throw throwSendMessageError! }
        return sendMessageDataReturn
    }

    func sendMessageParseMessage(msg: Domain.Message) async throws -> Domain.Message? {
        guard throwSendMessageError == nil else { throw throwSendMessageError! }
        return sendMessageReturn
    }
}
