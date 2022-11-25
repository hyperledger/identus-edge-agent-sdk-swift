import Domain
import Foundation

class MercuryStub: Mercury {
    var throwSendMessageError: Error?
    var throwUnpackError: Error?
    var throwPackageError: Error?
    var sendMessageReturn: Data?

    func packMessage(msg: Domain.Message) throws -> (result: String, signBy: String) {
        guard throwPackageError == nil else { throw throwPackageError! }
        let jsonStr = try JSONEncoder().encode(msg).base64EncodedString()
        return (jsonStr, "")
    }

    func unpackMessage(
        msg: String,
        options: Domain.UnpackOptions
    ) throws -> (result: Domain.Message, metadata: Domain.UnpackMetadata) {
        guard throwUnpackError == nil else { throw throwUnpackError! }
        let message = try JSONDecoder().decode(Message.self, from: Data(base64Encoded: msg)!)
        return (message, .init())
    }

    func sendMessage(msg: Domain.Message) async throws -> Data? {
        guard throwSendMessageError == nil else { throw throwSendMessageError! }
        return sendMessageReturn
    }
}
