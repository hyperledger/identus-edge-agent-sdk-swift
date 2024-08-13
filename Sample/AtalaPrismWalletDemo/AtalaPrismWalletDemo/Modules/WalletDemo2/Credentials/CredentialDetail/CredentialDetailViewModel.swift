import Combine
import Domain
import Foundation
import EdgeAgent

final class CredentialDetailViewModelImpl: CredentialDetailViewModel {
    @Published var credential = CredentialDetailViewState(
        issuer: "",
        claims: [:],
        credentialDefinitionId: nil,
        schemaId: nil
    )

    private let agent: DIDCommAgent
    private let credentialId: String

    init(agent: DIDCommAgent, credentialId: String) {
        self.agent = agent
        self.credentialId = credentialId
        bind()
    }

    private func bind() {
        let credentialId = self.credentialId
        return self.agent.edgeAgent
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
