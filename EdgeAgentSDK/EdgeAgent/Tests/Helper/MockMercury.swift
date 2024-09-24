import Domain
import Foundation

struct MockMercury: Mercury {
    func packMessage(msg: Domain.Message) async throws -> String {
        ""
    }
    
    func unpackMessage(msg: String) async throws -> Domain.Message {
        Message(piuri: "test", body: Data())
    }
    
    func sendMessage(_ msg: Domain.Message) async throws -> Data? {
        nil
    }
    
    func sendMessageParseMessage(msg: Domain.Message) async throws -> Domain.Message? {
        nil
    }
}
