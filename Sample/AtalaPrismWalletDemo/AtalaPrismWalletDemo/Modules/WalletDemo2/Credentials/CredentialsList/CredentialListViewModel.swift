import Combine
import Domain
import Foundation
import PrismAgent

final class CredentialListViewModelImpl: CredentialListViewModel {
    @Published var credentials = [CredentialListViewState.Credential]()

    private let agent: PrismAgent

    init(agent: PrismAgent) {
        self.agent = agent
        bind()
    }

    private func bind() {
        self.agent
            .verifiableCredentials()
            .map {
                $0.map {
                    CredentialListViewState.Credential(
                        id: $0.id,
                        issuer: $0.issuer,
                        issuanceDate: $0.storable?.queryCredentialCreated?.formatted() ?? "",
                        type: $0.credentialType
                    )
                }
            }
            .replaceError(with: [])
            .assign(to: &$credentials)
    }
}
