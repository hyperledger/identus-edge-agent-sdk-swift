import Combine
import Foundation
import PrismAgent

final class DashboardViewModelImpl: DashboardViewModel {
    @Published var toasty: FancyToast?
    // The initial module being presented in the TAB should be the center one
    // with index 2.
    @Published var selectedIndex: Int = 2
//    @Published var proofOfRequest: ProofOfRequestDomain?
    private var agent: PrismAgent
    private var cancellables = Set<AnyCancellable>()

    init(agent: PrismAgent) {
        self.agent = agent
        bind()
    }

    func middleButtonPressed() {
        selectedIndex = 2
    }

    func start() {
        Task { [weak self] in
            do {
                try await self?.agent.start()
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.toasty = .init(
                        type: .info,
                        title: "Achieved mediation",
                        message: "RoutingDID: \(self.agent.mediatorRoutingDID!)"
                    )
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.toasty = .init(
                        type: .error,
                        title: "Could not start agent",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    private func bind() {
//        proofOfRequestRepository
//            .getNext()
//            .delay(for: 1, scheduler: DispatchQueue.main)
//            .sink { [weak self] request in
//                self?.proofOfRequest = request
//            }
//            .store(in: &cancellables)
    }
}
