import Combine
import Foundation
import PrismAgent

final class CredentialDetailViewModelImpl: CredentialDetailViewModel {
    @Published var schema = ""
    @Published var types = [String]()
    @Published var issued = ""
    @Published var dismiss = false
    @Published var error: Error?

    private let credentialId: String
    private let agent: PrismAgent
    private var cancellables = Set<AnyCancellable>()

    init(
        credentialId: String,
        agent: PrismAgent
    ) {
        self.credentialId = credentialId
        self.agent = agent

        bind()
    }

    private func bind() {
        agent.verifiableCredentials()
            .map { [weak self] in
                $0.first { $0.id == self?.credentialId }
            }
            .replaceError(with: nil)
            .sink { [weak self] in
                guard let credential = $0 else { return }
                self?.schema = credential.credentialSchema?.type ?? ""
                self?.types = Array(credential.type)
                self?.issued = credential.issuanceDate.ISO8601Format()
            }
            .store(in: &cancellables)
    }
}
