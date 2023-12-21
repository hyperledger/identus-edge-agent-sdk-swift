import Domain
import Foundation
import PhotosUI
import PrismAgent
import SwiftUI

final class ChatViewModelImpl: ChatViewModel {
    @Published var name = ""
    @Published var sendingText = ""
    @Published var messages = [ChatViewState.Message]()
    @Published var error: FancyToast?
    @Published var selectedImage: Data?

    private let agent: PrismAgent
    private let pair: DIDPair
    private var messageList = Set<ChatViewState.Message>()

    init(conervsationPair: DIDPair, agent: PrismAgent) {
        self.agent = agent
        self.pair = conervsationPair
        self.name = conervsationPair.name ?? ""
        bind()
    }

    func bind() {
        let pair = self.pair
        agent.handleMessagesEvents()
            .filter {
                ($0.from == pair.other && $0.to == pair.holder) ||
                ($0.from == pair.holder && $0.to == pair.other)
            }
            .map { [try? BasicMessage(fromMessage: $0)].compactMap { $0 } }
            .replaceError(with: [])
            .map { [weak self] in
                $0.map {
                    ChatViewState.Message(
                        message: $0,
                        sent: $0.from == pair.other ? false : true
                    )
                }.forEach {
                    self?.messageList.insert($0)
                }
                return self?.messageList.sorted { $0.date < $1.date } ?? []
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$messages)
    }

    func sendMessage(text: String) {
        Task.detached { [weak self] in
            guard let self else { return }
            do {
                let image = selectedImage.flatMap { UIImage(data: $0) }.flatMap { $0.jpegData(compressionQuality: 0.001) }
                let sendingMessage = BasicMessage(
                    from: self.pair.holder,
                    to: self.pair.other,
                    body: .init(content: text),
                    attachments: image.map {
                        [AttachmentDescriptor(
                            id: "0",
                            mediaType: "image",
                            data: AttachmentBase64(base64: $0.base64EncodedString())
                        )]
                    } ?? []
                )
                _ = try await self.agent.sendMessage(message: sendingMessage.makeMessage())

                await MainActor.run {
                    self.messageList.insert(.init(message: sendingMessage, sent: true))
                    self.selectedImage = nil
                    self.messages = self.messageList.sorted { $0.date < $1.date }
                    self.sendingText = ""
                }
            } catch let error as LocalizedError {
                await MainActor.run { [weak self] in
                    self?.error = .init(
                        type: .error,
                        title: "Error",
                        message: error.errorDescription ?? error.localizedDescription
                    )
                }
            }
        }
    }

    func accept(id: String) {
        Task.detached { [weak self] in
            guard let self else { return }
            do {
                let message = try await self.agent.handleReceivedMessagesEvents()
                    .first { $0.id == id }
                    .await()
                guard 
                    message.direction == .received,
                    let msgType = ProtocolTypes(rawValue: message.piuri)
                else { return }
                switch msgType {
                case .didcommRequestPresentation:
                    let credential = try await self.agent.verifiableCredentials().map { $0.first }.first().await()
                    guard let credential else {
                        throw UnknownError.somethingWentWrongError()
                    }
                    let presentation = try await self.agent.createPresentationForRequestProof(
                        request: try RequestPresentation(fromMessage: message),
                        credential: credential
                    )
                    _ = try await self.agent.sendMessage(message: try presentation.makeMessage())
                case .didcommOfferCredential, .didcommOfferCredential3_0:
                    let newPrismDID = try await self.agent.createNewPrismDID()
                    guard let requestCredential = try await self.agent.prepareRequestCredentialWithIssuer(
                        did: newPrismDID,
                        offer: try OfferCredential3_0(fromMessage: message)
                    ) else { throw UnknownError.somethingWentWrongError() }
                    _ = try await self.agent.sendMessage(message: try requestCredential.makeMessage())
                default:
                    break
                }
            } catch let error as LocalizedError {
                await MainActor.run { [weak self] in
                    self?.error = .init(
                        type: .error,
                        title: "Error",
                        message: error.errorDescription ?? error.localizedDescription
                    )
                }
            }
        }
    }
}

private extension ChatViewState.Message {
    init(message: BasicMessage, sent: Bool) {
        self.date = message.date
        self.text = message.body.content
        self.sent = sent
        self.attachedImage = message.attachments
            .first { $0.mediaType == "image" }
            .map { $0.data as? AttachmentBase64 }?
            .flatMap { try? $0.decoded() }

        self.agentReceived = nil
        self.agentResponse = nil
    }

    init(message: OfferCredential3_0) {
        self.date = message.date
        self.text = ""
        self.sent = false
        self.attachedImage = nil
        self.agentReceived = .init(
            title: "Offer Credential",
            messageId: message.id,
            needsResponse: true
        )
        self.agentResponse = nil
    }

    init(message: IssueCredential3_0) {
        self.date = message.date
        self.text = ""
        self.sent = false
        self.attachedImage = nil
        self.agentReceived = .init(
            title: "Issued Credential",
            messageId: message.id,
            needsResponse: false
        )
        self.agentResponse = nil
    }

    init(message: RequestPresentation) {
        self.date = message.date
        self.text = ""
        self.sent = false
        self.attachedImage = nil
        self.agentReceived = .init(
            title: "Issued Credential",
            messageId: message.id,
            needsResponse: false
        )
        self.agentResponse = nil
    }
}
