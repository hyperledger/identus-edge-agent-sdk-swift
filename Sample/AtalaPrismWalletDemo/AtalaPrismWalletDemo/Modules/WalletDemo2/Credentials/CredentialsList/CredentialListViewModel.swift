import Combine
import Domain
import Foundation

final class CredentialListViewModelImpl: CredentialListViewModel {
    @Published var credentials = [CredentialListViewState.Credential]()

    private let pluto: Pluto

    init(pluto: Pluto) {
        self.pluto = pluto
        bind()
    }

    private func bind() {
        self.pluto
            .getAllCredentials()
            .map {
                $0.map {
                    CredentialListViewState.Credential(
                        credentialType: getTypeString(type: $0.credentialType),
                        id: $0.id,
                        issuer: $0.issuer.string,
                        issuanceDate: $0.issuanceDate.formatted(),
                        context: Array($0.context),
                        type: Array($0.type)
                    )
                }
            }
            .replaceError(with: [])
            .assign(to: &$credentials)
    }
}

private func getTypeString(type: CredentialType) -> String {
    switch type {
    case .jwt:
        return "jwt"
    case .w3c:
        return "w3c"
    default:
        return "unknown"
    }
}
