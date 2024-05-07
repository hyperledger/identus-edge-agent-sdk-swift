import Combine
import Domain
import Foundation
import Pluto
import EdgeAgent

class PresentationsViewModelImpl: PresentationsViewModel {
    @Published var presentations: [PresentationsViewState.Presentation] = []
    private let pluto: Pluto
    private let agent: EdgeAgent

    init(pluto: Pluto, agent: EdgeAgent) {
        self.pluto = pluto
        self.agent = agent
        bind()
    }

    func bind() {
        pluto.getAllMessages().map { messages in
            messages.compactMap { try? RequestPresentation(fromMessage: $0) }
                .compactMap { [weak self] in
                    self?.getPresentationStateFrom(message: $0, messagesList: messages)
                }
        }
        .replaceError(with: [])
        .assign(to: &$presentations)
    }

    private func getPresentationStateFrom(
        message: RequestPresentation,
        messagesList: [Message]
    ) -> PresentationsViewState.Presentation? {
        return PresentationsViewState.Presentation(id: message.id, name: message.id, to: message.to.string)
    }
}
