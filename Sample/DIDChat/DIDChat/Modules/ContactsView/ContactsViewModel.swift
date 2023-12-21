import Combine
import Domain
import Foundation
import PrismAgent

class ContactsViewModelImpl: ContactsViewModel {
    @Published var createdPeerDIDAlias: String?
    @Published var createdPeerDID: String?
    @Published var contacts = [ContactsViewState.Contact]()
    @Published var error: Error?
    private var addingContact = false
    private var cancellables = Set<AnyCancellable>()

    let agent: PrismAgent

    init(prismAgent: PrismAgent) {
        self.agent = prismAgent

        bind()
    }

    func bind() {
        agent
            .getAllDIDPairs()
            .flatMap { [weak self] in
                Publishers.Sequence(sequence: $0.map { didPair in
                    Future<(DIDPair, Bool), Error> {
                        let verified = await self?.didPairHasPresentation(didPair: didPair)
                        return (didPair, verified ?? false)
                    }
                })
                .flatMap { $0 }
                .collect()
                .eraseToAnyPublisher()
            }
            .map {
                $0.map {
                    ContactsViewState.Contact(
                        id: $0.0.other.string,
                        name: $0.0.name ?? "",
                        pair: $0.0,
                        verified: $0.1
                    )
                }
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: &$contacts)

        agent
            .getAllDIDPairs()
            .flatMap { [weak self] in
                Publishers.Sequence(sequence: $0.map { didPair in
                    Future<Void, Error> {
                        try? await self?.sendPresentationRequestMessage(didPair: didPair)
                    }
                })
                .flatMap { $0 }
                .collect()
                .eraseToAnyPublisher()
            }
            .sink { _ in } receiveValue: { _ in }
            .store(in: &cancellables)


        agent
            .handleReceivedMessagesEvents()
            .sink { _ in } receiveValue: { [weak self] in
                self?.automaticProcess(message: $0)
            }
            .store(in: &cancellables)

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
                print(holderDID.string)
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

    func connectWithAgent(agentName: String, agentOOB: String) {
        Task.detached { [weak self] in
            guard let self else { return }
            do {
                let inv = try self.agent.parseOOBInvitation(url: agentOOB)
                try await self.agent.acceptDIDCommInvitation(invitation: inv, alias: agentName)
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }

    func automaticProcess(message: Message) {
        guard
            message.direction == .received,
            let msgType = ProtocolTypes(rawValue: message.piuri)
        else { return }
        let agent = self.agent
        Task.detached { [weak self] in
            do {
                switch msgType {
                case .didcommIssueCredential, .didcommIssueCredential3_0:
                    let issueCredential = try IssueCredential3_0(fromMessage: message)
                    _ = try await agent.processIssuedCredentialMessage(message: issueCredential)
                default:
                    break
                }
            } catch let error as LocalizedError {
                await MainActor.run { [weak self] in
                    self?.error = error
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.error = error
                }
            }
        }
    }

    func didPairHasPresentation(didPair: DIDPair) async -> Bool {
        (try? await agent.messagesReceivedForDIDPair(didPair: didPair)
            .first()
            .map {
                $0.contains { $0.piuri == "https://didcomm.atalaprism.io/present-proof/3.0/presentation" }
            }
            .first()
            .await()) ?? false
    }

    func didPairHasPresentationBeenRequested(didPair: DIDPair) async -> Bool {
        (try? await agent.messagesSentForDIDPair(didPair: didPair)
            .first()
            .map {
                $0.contains { $0.piuri == "https://didcomm.atalaprism.io/present-proof/3.0/request-presentation" }
            }
            .first()
            .await()) ?? false
    }

    func sendPresentationRequestMessage(didPair: DIDPair) async throws {
        let verified = await didPairHasPresentation(didPair: didPair)
        let requestSent = await didPairHasPresentationBeenRequested(didPair: didPair)

        if !verified && !requestSent {
            let request = RequestPresentation(
                body: .init(
                    proofTypes: [
                        .init(
                            schema: "nameSchema",
                            requiredFields: ["name"],
                            trustIssuers: nil)
                    ]
                ),
                attachments: [.init(
                    data: AttachmentJsonData(data: try "{\"domain\":\"domain\",\"challenge\":\"challenge\"}".tryData(using: .utf8)))
                ],
                thid: nil,
                from: didPair.holder,
                to: didPair.other
            )

            _ = try await agent.sendMessage(message: request.makeMessage())
        }
    }
}
