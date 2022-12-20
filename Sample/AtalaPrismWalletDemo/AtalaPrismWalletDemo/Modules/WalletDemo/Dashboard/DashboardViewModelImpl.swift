import Combine
import Foundation
import PrismAgent

final class DashboardViewModelImpl: DashboardViewModel {
    @Published var toasty: FancyToast?
    // The initial module being presented in the TAB should be the center one
    // with index 2.
    @Published var selectedIndex: Int = 2
    @Published var proofOfRequest: RequestPresentation?
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
        agent.requestedPresentations
            .map {
                $0.filter { !$0.1 }
            }
            .map {
                $0.sorted { $0.0.id < $1.0.id }
            }
            .map {
                $0.first
            }
            .receive(on: DispatchQueue.main)
            .sink {
                self.proofOfRequest = $0?.0
            }
            .store(in: &cancellables)
    }
}
