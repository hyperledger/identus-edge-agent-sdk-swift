import Combine
import Domain
import Foundation
import EdgeAgent
import OpenID4VCI

final class AddNewContactViewModelImpl: AddNewContactViewModel {
    @Published var flowStep: AddNewContactState.AddContacFlowStep
    @Published var code = ""
    @Published var dismiss = false
    @Published var dismissRoot = false
    @Published var loading = false
    @Published var contactInfo: AddNewContactState.Contact?
    @Published var url: URL?
    @Published var hasUrl: Bool = false

    private let pluto: Pluto
    private let agent: DIDCommAgent
    private let oidcAgent: OIDCAgent
    private var cancellables = Set<AnyCancellable>()
    private var issuer: Issuer?
    private var offer: CredentialOffer?
    private var request: UnauthorizedRequest?

    init(
        token: String = "",
        agent: DIDCommAgent,
        oidcAgent: OIDCAgent,
        pluto: Pluto
    ) {
        code = token
        self.agent = agent
        self.oidcAgent = oidcAgent
        self.pluto = pluto
        flowStep = token.isEmpty ? .getCode : .checkDuplication
    }

    func isContactAlreadyAdded() {
        guard !loading else { return }
        loading = true
        Task { [weak self] in
            guard
                let self
            else { return }

            do {
                if let recipientDID = try? DID(string: self.code) {
                    let didPairs = try await agent.edgeAgent.getAllDIDPairs().first().await()

                    await MainActor.run { [weak self] in
                        guard didPairs.first(where: { $0.other.string == recipientDID.string }) == nil else {
                            self?.flowStep = .alreadyConnected
                            self?.loading = false
                            return
                        }

                        self?.contactInfo = .init(text: recipientDID.string)
                        self?.flowStep = .confirmConnection
                        self?.loading = false
                    }

                } else if self.code.contains("openid-credential-offer"){
                    let offer = try await oidcAgent.parseCredentialOffer(offerUri: self.code)
                    self.offer = offer
                    let prePreparedRequest = try await oidcAgent.createAuthorizationRequest(
                        clientId: "alice-wallet",
                        redirectUri: URL(string: "edgeagentsdk://oidc")!,
                        offer: offer
                    )
                    self.issuer = prePreparedRequest.0
                    self.request = prePreparedRequest.1
                    switch self.request {
                    case .par(let parRequested):
                        self.url = parRequested.getAuthorizationCodeURL.url
                        self.hasUrl = true
                    default:
                        throw UnknownError.somethingWentWrongError(customMessage: nil, underlyingErrors: nil)
                    }
                } else {
                    let connection = try agent.parseOOBInvitation(url: self.code)
                    let didPairs = try await agent.edgeAgent.getAllDIDPairs().first().await()

                    await MainActor.run { [weak self] in
                        guard didPairs.first(where: { $0.other.string == connection.from }) == nil else {
                            self?.flowStep = .alreadyConnected
                            self?.loading = false
                            return
                        }

                        self?.contactInfo = .init(text: connection.from)
                        self?.flowStep = .confirmConnection
                        self?.loading = false
                    }
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.flowStep = .error(DisplayErrorState(error: error))
                    self?.loading = false
                }
            }
        }
    }

    func handleLinkCallback(url: URL) async throws {
        hasUrl = false
        let response = try await oidcAgent.handleTokenRequest(
            request: request!,
            issuer: issuer!,
            callbackUrl: url
        )
        let credential = try await oidcAgent.credentialRequest(
            issuer: response.0,
            offer: offer!,
            request: response.1
        )
        loading = false
        dismiss = true
        print(credential)
    }

    func addContact() {
        guard contactInfo != nil, !loading else { return }
        loading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                guard let recipientDID = try? DID(string: self.code) else {
                    let connection = try agent.parseOOBInvitation(url: self.code)
                    try await self.agent.acceptDIDCommInvitation(invitation: connection)
                    await MainActor.run { [weak self] in
                        self?.dismiss = true
                        self?.dismissRoot = true
                        self?.loading = false
                    }
                    return
                }
                let newPeerDID = try await agent.createNewPeerDID(updateMediator: true)
                let message = BasicMessage(from: newPeerDID, to: recipientDID, body: .init(content: "Text"))
                let messageConnection = ConnectionRequest(from: newPeerDID, to: recipientDID, thid: nil, body: .init())
                try await self.pluto.storeDIDPair(pair: .init(holder: message.from, other: message.to, name: nil)).first().await()
                _ = try await agent.sendMessage(message: message.makeMessage())
                _ = try await agent.sendMessage(message: messageConnection.makeMessage())
                await MainActor.run { [weak self] in
                    self?.dismiss = true
                    self?.dismissRoot = true
                    self?.loading = false
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.flowStep = .error(DisplayErrorState(error: error))
                    self?.loading = false
                }
            }
        }
    }
}
