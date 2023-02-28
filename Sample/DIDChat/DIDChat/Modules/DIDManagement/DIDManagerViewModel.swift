import Combine
import Domain
import Foundation
import PrismAgent

class DIDManagerViewModelImpl: DIDManagerViewModel {
    @Published var dids = [DIDManagerState.DIDInfo]()

    private let agent: PrismAgent

    init(agent: PrismAgent) {
        self.agent = agent

        bind()
    }

    private func bind() {
        agent.getAllRegisteredPeerDIDs()
            .map {
                $0.map {
                    DIDManagerState.DIDInfo(
                        didString: $0.did.string,
                        alias: $0.alias
                    )
                }
            }
            .replaceError(with: [])
            .assign(to: &$dids)
    }
}
