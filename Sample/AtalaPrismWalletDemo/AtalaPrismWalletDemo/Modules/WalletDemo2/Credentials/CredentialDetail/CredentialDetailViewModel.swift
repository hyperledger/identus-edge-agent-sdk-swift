import Combine
import Domain
import Foundation
import PrismAgent

final class CredentialDetailViewModelImpl: CredentialDetailViewModel {
    @Published var credential = CredentialDetailViewState(
        issuer: "",
        claims: [:],
        credentialDefinitionId: nil,
        schemaId: nil
    )

    private let agent: PrismAgent
    private let credentialId: String

    init(agent: PrismAgent, credentialId: String) {
        self.agent = agent
        self.credentialId = credentialId
        bind()
    }

    private func bind() {
        let credentialId = self.credentialId
        return self.agent
            .verifiableCredentials()
            .map {
                if let credential = $0.first(where: { $0.id == credentialId }) {
                    return CredentialDetailViewState(
                        issuer: credential.issuer,
                        claims: credential.claims.reduce(into: [String: String](), { partialResult, claim in
                            partialResult[claim.key] = claim.getValueAsString()
                        }),
                        credentialDefinitionId: credential.properties["credentialDefinitionId"] as? String,
                        schemaId: credential.properties["schemaId"] as? String
                    )
                } else {
                    return CredentialDetailViewState(
                        issuer: "",
                        claims: [:],
                        credentialDefinitionId: nil,
                        schemaId: nil
                    )
                }
            }
            .replaceError(with: CredentialDetailViewState(
                issuer: "",
                claims: [:],
                credentialDefinitionId: nil,
                schemaId: nil
            ))
            .assign(to: &$credential)
    }
}
