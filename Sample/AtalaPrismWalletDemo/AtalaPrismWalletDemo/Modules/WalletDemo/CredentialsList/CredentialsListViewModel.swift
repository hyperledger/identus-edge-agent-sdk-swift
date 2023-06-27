import Combine
import Domain
import Foundation
import PrismAgent

final class CredentialsListViewModelImpl: CredentialsListViewModel {
    @Published var credentials = [CredentialsListState.Credential]()
    @Published var showEmptyList = false

    private let agent: PrismAgent
    private var cancellables = Set<AnyCancellable>()

    init(agent: PrismAgent) {
        self.agent = agent

        bind()
    }

    private func bind() {
        agent.verifiableCredentials()
            .map {
                $0.map { mapCredentialType($0) }.sorted { $0.id < $1.id }
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: &$credentials)

        $credentials
            .map { $0.isEmpty }
            .assign(to: &$showEmptyList)

        agent.handleReceivedMessagesEvents()
            .sink { _ in } receiveValue: { _ in}
            .store(in: &cancellables)
    }
}

private func mapCredentialType(
    _ credential: Credential
) -> CredentialsListState.Credential {
    .init(
        id: credential.id,
        icon: .name(""),
        title: credential.claims.sorted { $0.key < $1.key }.first?.getValueAsString() ?? "",
        subtitle: credential.claims.sorted { $0.key < $1.key }.last?.getValueAsString() ?? ""
    )
}
