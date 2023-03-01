import Domain
import Foundation
import PrismAgent

final class ChatViewModelImpl: ChatViewModel {
    @Published var name = ""
    @Published var sendingText = ""
    @Published var messages = [ChatViewState.Message]()

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
                        date: $0.date,
                        text: $0.body.content,
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
            let sendingMessage = BasicMessage(
                from: self.pair.holder,
                to: self.pair.other,
                body: .init(content: text)
            )
            _ = try await self.agent.sendMessage(message: sendingMessage.makeMessage())

            await MainActor.run {
                self.messageList.insert(.init(
                    date: sendingMessage.date,
                    text: sendingMessage.body.content,
                    sent: true
                ))

                self.messages = self.messageList.sorted { $0.date < $1.date }
                self.sendingText = ""
            }
        }
    }
}
