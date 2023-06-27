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
                        credentialType: "",
                        id: $0.id,
                        issuer: $0.issuer,
                        issuanceDate: "",//$0.issuanceDate.formatted(),
                        context: [""],
                        type: [""]
                    )
                }
            }
            .replaceError(with: [])
            .assign(to: &$credentials)
    }
}
