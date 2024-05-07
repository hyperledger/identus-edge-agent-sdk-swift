import Combine
import Domain
import Foundation
import EdgeAgent

class DIDManagerViewModelImpl: DIDManagerViewModel {
    @Published var dids = [DIDManagerState.DIDInfo]()

    private let agent: EdgeAgent

    init(agent: EdgeAgent) {
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
