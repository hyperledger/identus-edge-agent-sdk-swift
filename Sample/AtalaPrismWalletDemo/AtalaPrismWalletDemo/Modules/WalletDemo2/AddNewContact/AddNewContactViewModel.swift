import Combine
import Domain
import Foundation
import EdgeAgent

final class AddNewContactViewModelImpl: AddNewContactViewModel {
    @Published var flowStep: AddNewContactState.AddContacFlowStep
    @Published var code = ""
    @Published var dismiss = false
    @Published var dismissRoot = false
    @Published var loading = false
    @Published var contactInfo: AddNewContactState.Contact?

    private let pluto: Pluto
    private let agent: EdgeAgent
    private var cancellables = Set<AnyCancellable>()

    init(
        token: String = "",
        agent: EdgeAgent,
        pluto: Pluto
    ) {
        code = token
        self.agent = agent
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
                    let didPairs = try await agent.getAllDIDPairs().first().await()

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

                } else {
                    let connection = try agent.parseOOBInvitation(url: self.code)
                    let didPairs = try await agent.getAllDIDPairs().first().await()

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
