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
            .map { $0.map { mapCredentialType($0) }.sorted { $0.id < $1.id } }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: &$credentials)
    }
}

private func mapCredentialType(
    _ credential: VerifiableCredential
) -> CredentialsListState.Credential {
    .init(
        id: credential.id,
        icon: .name(""),
        title: credential.credentialSchema?.type ?? "",
        subtitle: credential.type.joined(separator: " ")
    )
}
