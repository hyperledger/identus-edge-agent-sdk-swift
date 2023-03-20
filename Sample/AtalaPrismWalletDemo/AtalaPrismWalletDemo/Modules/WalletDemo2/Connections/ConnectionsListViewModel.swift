import Combine
import Domain
import Foundation
import PrismAgent

final class ConnectionsListViewModelImpl: ConnectionsListViewModel {
    @Published var connections = [ConnectionsViewState.Connection]()
    @Published var error: FancyToast?

    private let castor: Castor
    private let pluto: Pluto
    private let agent: PrismAgent

    init(castor: Castor, pluto: Pluto, agent: PrismAgent) {
        self.castor = castor
        self.pluto = pluto
        self.agent = agent

        bind()
    }

    func bind() {
        agent
            .getAllDIDPairs()
            .map {
                $0.map {
                    ConnectionsViewState.Connection(
                        hostDID: $0.holder.string,
                        recipientDID: $0.other.string,
                        alias: $0.name
                    )
                }
            }
            .replaceError(with: [])
            .assign(to: &$connections)
    }

    func addConnection(invitation: String, alias: String) {
        let castor = self.castor
        let agent = self.agent
        Task { [weak self] in
            do {
                if let did = try? castor.parseDID(str: invitation) {
                    let hostDID = try await agent.createNewPeerDID(
                        alias: alias.isEmpty ? nil : alias,
                        updateMediator: true
                    )
                    let connectionRequest = ConnectionRequest(
                        from: hostDID,
                        to: did,
                        thid: nil,
                        body: .init()
                    )
                    _ = try await agent.sendMessage(message: connectionRequest.makeMessage())
                } else if let url = URL(string: invitation) {
                    let inv = try agent.parseOOBInvitation(url: url)
                    try await agent.acceptDIDCommInvitation(invitation: inv)
                }
            } catch let error as LocalizedError {
                await MainActor.run { [weak self] in
                    self?.error = FancyToast(
                        type: .error,
                        title: error.localizedDescription,
                        message: error.errorDescription ?? ""
                    )
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.error = FancyToast(
                        type: .error,
                        title: error.localizedDescription,
                        message: ""
                    )
                }
            }
        }
    }
}
