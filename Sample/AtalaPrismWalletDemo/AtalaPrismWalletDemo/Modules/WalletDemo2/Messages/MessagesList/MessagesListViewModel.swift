import Domain
import Combine
import Foundation
import PrismAgent

final class MessagesListViewModelImpl: MessageListViewModel {
    @Published var messages = [MessagesListViewState.Message]()
    @Published var error: FancyToast?

    private let agent: PrismAgent
    private var messagesDomain = Set<Message>() {
        didSet {
            messages = messagesDomain
                .sorted { $0.createdTime < $1.createdTime }
                .map {
                    let did = ($0.direction == .received ? $0.from : $0.to)?.string
                    return MessagesListViewState.Message(
                        id: $0.id,
                        title: self.getMessageTitle(messageType: $0.piuri),
                        did: did,
                        received: $0.direction == .received
                    )
                }
        }
    }
    private var cancellables = Set<AnyCancellable>()

    init(agent: PrismAgent) {
        self.agent = agent
        bind()
    }

    func bind() {
        agent
            .handleMessagesEvents()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.automaticProcess(message: $0)
                self?.messagesDomain.insert($0)
            })
            .store(in: &cancellables)
    }

    func getMessageTitle(messageType: String) -> String {
        guard let msgType = ProtocolTypes(rawValue: messageType) else {
            return messageType
        }
        return getTitle(for: msgType)
    }

    func getTitle(for protocolType: ProtocolTypes) -> String {
        switch protocolType {
        case .didcommBasicMessage:
            return "Basic Message"
        case .didcommMediationRequest:
            return "Mediation Request"
        case .didcommMediationGrant:
            return "Mediation Grant"
        case .didcommMediationDeny:
            return "Mediation Deny"
        case .didcommMediationKeysUpdate:
            return "Mediation Keys Update"
        case .didcommPresentation:
            return "Presentation"
        case .didcommRequestPresentation:
            return "Request Presentation"
        case .didcommProposePresentation:
            return "Propose Presentation"
        case .didcommCredentialPreview:
            return "Credential Preview"
        case .didcommIssueCredential:
            return "Issue Credential"
        case .didcommIssueCredential3_0:
            return "Issue Credential 3.0"
        case .didcommOfferCredential:
            return "Offer Credential"
        case .didcommOfferCredential3_0:
            return "Offer Credential 3.0"
        case .didcommProposeCredential:
            return "Propose Credential"
        case .didcommProposeCredential3_0:
            return "Propose Credential 3.0"
        case .didcommRequestCredential:
            return "Request Credential"
        case .didcommRequestCredential3_0:
            return "Request Credential 3.0"
        case .didcommconnectionRequest:
            return "Connection Request"
        case .didcommconnectionResponse:
            return "Connection Response"
        case .didcomminvitation:
            return "Invitation"
        case .prismOnboarding:
            return "Prism Onboarding"
        case .pickupRequest:
            return "Pickup Request"
        case .pickupDelivery:
            return "Pickup Delivery"
        case .pickupStatus:
            return "Pickup Status"
        case .pickupReceived:
            return "Pickup Received"
        case .didcommCredentialPreview3_0:
            return "Credential Preview"
        }
    }

    func automaticProcess(message: Message) {
        guard
            message.direction == .received,
            let msgType = ProtocolTypes(rawValue: message.piuri)
        else { return }
        let agent = self.agent
        Task.detached { [weak self] in
            do {
                switch msgType {
                case .didcommconnectionResponse:
                    guard
                        let from = message.from,
                        let to = message.to
                    else { return }

                    try await agent.registerDIDPair(pair: .init(
                        holder: from,
                        other: to,
                        name: nil
                    ))
                case .didcommIssueCredential, .didcommIssueCredential3_0:
                    let issueCredential = try IssueCredential3_0(fromMessage: message)
                    _ = try await agent.processIssuedCredentialMessage(message: issueCredential)
                default:
                    break
                }
            } catch let error as LocalizedError {
                await MainActor.run { [weak self] in
                    self?.error = FancyToast(
                        type: .error,
                        title: error.localizedDescription,
                        message: error.errorDescription ?? ""
                    )
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.error = FancyToast(
                        type: .error,
                        title: error.localizedDescription,
                        message: ""
                    )
                }
            }
        }
    }
}
