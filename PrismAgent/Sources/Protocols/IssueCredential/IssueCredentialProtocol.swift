import Core
import Domain
import Foundation

public class IssueCredentialProtocol {
    public enum Stage {
        case propose
        case offer
        case request
        case completed
        case refused
    }

    public private(set) var stage: Stage
    let connector: DIDCommConnection
    var propose: ProposeCredential?
    var offer: OfferCredential?
    var request: RequestCredential?

    public init(_ message: Message, connector: DIDCommConnection) throws {
        if let proposed = try? ProposeCredential(fromMessage: message) {
            self.stage = .propose
            self.propose = proposed
        } else if let offered = try? OfferCredential(fromMessage: message) {
            self.stage = .offer
            self.offer = offered
        } else if let requested = try? RequestCredential(fromMessage: message) {
            self.stage = .request
            self.request = requested
        } else {
            throw PrismAgentError.invalidStepError
        }
        self.connector = connector
    }

    init(
        stage: Stage,
        propose: Message? = nil,
        offer: Message? = nil,
        request: Message? = nil,
        connector: DIDCommConnection
    ) throws {
        self.stage = stage
        self.propose = try propose.map { try ProposeCredential(fromMessage: $0) }
        self.offer = try offer.map { try OfferCredential(fromMessage: $0) }
        self.request = try request.map { try RequestCredential(fromMessage: $0) }
        self.connector = connector
    }

    public func nextStage() async throws {
        let messageId: String?
        switch stage {
        case .propose:
            guard let propose else {
                stage = .refused
                return
            }
            let message = try OfferCredential.makeOfferFromProposedCredential(proposed: propose)
            try await connector.sendMessage(message.makeMessage())
            messageId = message.id
        case .offer:
            guard let offer else {
                stage = .refused
                return
            }
            let message = try RequestCredential.makeRequestFromOfferCredential(offer: offer).makeMessage()
            try await connector.sendMessage(message)
            messageId = message.id
        case .request:
            return
//            guard let request else {
//                stage = .refused
//                return
//            }
//            try await connector.sendMessage(message.makeMessage())
        case .completed:
            return
        case .refused:
            return
        }
        guard
            let messageId,
            let response = try await connector.awaitMessageResponse(id: messageId)
        else { return }
        if let offer = try? OfferCredential(fromMessage: response) {
            stage = .offer
            self.offer = offer
        } else if let request = try? RequestCredential(fromMessage: response) {
            stage = .request
            self.request = request
        } else if let issued = try? IssueCredential(fromMessage: response) {
            stage = .completed
        }
    }
}
