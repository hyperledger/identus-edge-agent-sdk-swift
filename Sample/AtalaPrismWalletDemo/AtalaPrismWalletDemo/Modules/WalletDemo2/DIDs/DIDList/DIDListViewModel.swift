import Combine
import Domain
import Foundation
import PrismAgent

final class DIDListViewModelImpl: DIDListViewModel {
    @Published var peerDIDs = [DIDListViewState.DID]()
    @Published var prismDIDs = [DIDListViewState.DID]()
    @Published var error: FancyToast?

    private let pluto: Pluto
    private let agent: PrismAgent

    init(pluto: Pluto, agent: PrismAgent) {
        self.pluto = pluto
        self.agent = agent

        bind()
    }

    func bind() {
        pluto
            .getAllPeerDIDs()
            .map {
                $0.map {
                    DIDListViewState.DID(
                        did: $0.did.string,
                        alias: $0.alias
                    )
                }
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: &$peerDIDs)

        pluto
            .getAllPrismDIDs()
            .map {
                $0.map {
                    DIDListViewState.DID(
                        did: $0.did.string,
                        alias: $0.alias
                    )
                }
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: &$prismDIDs)
    }

    func addPeerDID() {
        Task.detached { [weak self] in
            do {
                _ = try await self?.agent.createNewPeerDID(updateMediator: true)
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

    func addPrismDID() {
        Task.detached { [weak self] in
            do {
                _ = try await self?.agent.createNewPrismDID()
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
