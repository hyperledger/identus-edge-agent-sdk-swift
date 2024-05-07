import Combine
import Domain
import Foundation
import EdgeAgent

final class ConnectionsListViewModelImpl: ConnectionsListViewModel {
    @Published var connections = [ConnectionsViewState.Connection]()
    @Published var error: FancyToast?

    private var cancellables = Set<AnyCancellable>()
    private let castor: Castor
    private let pluto: Pluto
    private let agent: EdgeAgent

    init(castor: Castor, pluto: Pluto, agent: EdgeAgent) {
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

        agent
            .handleReceivedMessagesEvents()
            .filter {
                $0.piuri == ProtocolTypes.didcommconnectionRequest.rawValue
            }
            .flatMap { message in
                Future {
                    guard try await !self.pluto.getAllDidPairs().first().await().contains(where: { $0.other == message.from }) else {
                        return ()
                    }
                    try await self.pluto.storeDIDPair(pair: .init(holder: message.to!, other: message.from!, name: nil)).first().await()
                    let response = ConnectionAccept(from: message.to!, to: message.from!, thid: message.thid ?? message.id, body: .init())
                    _ = try await self.agent.sendMessage(message: response.makeMessage())
                }
            }
            .sink { _ in } receiveValue: { _ in }
            .store(in: &cancellables)

        agent
            .handleReceivedMessagesEvents()
            .filter {
                $0.piuri == ProtocolTypes.didcommconnectionResponse.rawValue
            }
            .flatMap { message in
                Future {
                    guard try await !self.pluto.getAllDidPairs().first().await().contains(where: { $0.other == message.from }) else {
                        return ()
                    }
                    try await self.pluto.storeDIDPair(pair: .init(holder: message.to!, other: message.from!, name: nil)).first().await()
                }
            }
            .sink { _ in } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func addConnection(invitation: String, alias: String) {
        let castor = self.castor
        let agent = self.agent
        Task.detached { [weak self] in
            do {
                if let did = try? castor.parseDID(str: invitation) {
                    let hostDID = try await agent.createNewPeerDID(
                        alias: alias.isEmpty ? nil : alias,
                        updateMediator: true
                    )
//                    let connectionRequest = ConnectionRequest(
//                        from: hostDID,
//                        to: did,
//                        thid: nil,
//                        body: .init()
//                    )
//                    let basicMessage = BasicMessage(
//                        from: hostDID,
//                        to: did,
//                        body: .init(content: "Test")
//                    )
//                    _ = try await agent.sendMessage(message: basicMessage.makeMessage())
                    try await self?.pluto.storeDIDPair(pair: .init(holder: hostDID, other: did, name: "Javi")).first().await()
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
