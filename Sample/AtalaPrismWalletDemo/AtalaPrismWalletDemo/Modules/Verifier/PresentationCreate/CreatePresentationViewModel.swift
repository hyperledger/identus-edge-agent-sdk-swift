import Combine
import Domain
import Foundation
import EdgeAgent

class CreatePresentationViewModelImpl: CreatePresentationViewModel {
    @Published var selectedConnection: CreatePresentationViewState.Connection? = nil
    @Published var connections: [CreatePresentationViewState.Connection] = []
    @Published var toDID: String = ""
    @Published var selectedCredentialType: CreatePresentationViewState.CredentialType = .jwt
    @Published var jwtClaims: [CreatePresentationViewState.JWTClaim] = []
    @Published var anoncredsClaims: [CreatePresentationViewState.AnoncredsClaim] = []
    private let agent: EdgeAgent

    init(edgeAgent: EdgeAgent) {
        self.agent = edgeAgent

        bind()
    }

    func bind() {
        agent
            .getAllDIDPairs()
            .map {
                $0.map {
                    .init(alias: $0.name ?? "", hostDID: $0.holder, recipientDID: $0.other)
                }
            }
            .replaceError(with: [])
            .assign(to: &$connections)

        $connections.map { $0.first }.assign(to: &$selectedConnection)
    }

    func addJWTClaim() {
        jwtClaims.append(CreatePresentationViewState.JWTClaim())
    }

    func addAnoncredsClaim() {
        anoncredsClaims.append(CreatePresentationViewState.AnoncredsClaim())
    }

    func addPath(to claimIndex: Int, path: String) {
        if jwtClaims.indices.contains(claimIndex) {
            jwtClaims[claimIndex].paths.append(path)
        }
    }

    func removePath(from claimIndex: Int, at pathIndex: Int) {
        if jwtClaims.indices.contains(claimIndex),
           jwtClaims[claimIndex].paths.indices.contains(pathIndex) {
            jwtClaims[claimIndex].paths.remove(at: pathIndex)
        }
    }

    func createPresentation() async throws {
        guard let selectedConnection else {
            throw UnknownError.somethingWentWrongError(customMessage: nil, underlyingErrors: nil)
        }
        switch selectedCredentialType {
        case .jwt:
            let request = try await agent.initiatePresentationRequest(
                type: .jwt,
                fromDID: selectedConnection.hostDID,
                toDID: selectedConnection.recipientDID,
                claimFilters: jwtClaims.map {
                    ClaimFilter(
                        paths: $0.paths,
                        type: $0.type.lowercased(),
                        required: $0.required,
                        name: $0.name.isEmpty ? nil :  $0.name,
                        format: $0.format.isEmpty ? nil : $0.format,
                        const: $0.const.isEmpty ? nil : $0.const,
                        pattern: $0.pattern.isEmpty ? nil : $0.pattern
                    )
                }
            )

            _ = try await agent.sendMessage(message: request.makeMessage())
        case .anoncreds:
            let request = try await agent.initiatePresentationRequest(
                type: .anoncred,
                fromDID: selectedConnection.hostDID,
                toDID: selectedConnection.recipientDID,
                claimFilters: anoncredsClaims.map {
                    ClaimFilter(
                        paths: [],
                        type: "",
                        required: true,
                        name: $0.name,
                        format: nil,
                        const: nil,
                        pattern: $0.predicate
                    )
                }
            )
            _ = try await agent.sendMessage(message: request.makeMessage())
        }
    }
}
