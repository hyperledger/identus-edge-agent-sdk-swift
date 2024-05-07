import Combine
import Domain
import Foundation
import EdgeAgent

class ContactsViewModelImpl: ContactsViewModel {
    @Published var createdPeerDIDAlias: String?
    @Published var createdPeerDID: String?
    @Published var contacts = [ContactsViewState.Contact]()
    @Published var error: Error?
    private var addingContact = false

    let agent: EdgeAgent

    init(edgeAgent: EdgeAgent) {
        self.agent = edgeAgent

        bind()
    }

    func bind() {
        agent.getAllDIDPairs()
            .map {
                $0.map {
                    ContactsViewState.Contact(
                        id: $0.other.string,
                        name: $0.name ?? "",
                        pair: $0
                    )
                }
            }
            .replaceError(with: [])
            .assign(to: &$contacts)
    }

    func addContact(name: String, didString: String) {
        guard !addingContact else { return }
        addingContact = true
        let agent = self.agent
        Task.detached { [weak self] in
            guard let self else { return }
            do {
                let otherDID = try DID(string: didString)
                let holderDID = try await agent.createNewPeerDID(alias: name, updateMediator: true)
                let connectionRequest = ConnectionRequest(
                    from: holderDID,
                    to: otherDID,
                    thid: nil,
                    body: .init()
                )
                _ = try await agent.sendMessage(message: connectionRequest.makeMessage())
                self.addingContact = false
            } catch {
                self.addingContact = false
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }

    func createNewPeerDIDForConnection(alias: String) {
        Task.detached { [weak self] in
            guard let self else { return }
            do {
                let holderDID = try await self.agent.createNewPeerDID(alias: alias, updateMediator: true)
                await MainActor.run {
                    self.createdPeerDID = holderDID.string
                    self.createdPeerDIDAlias = alias
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
}
