import Combine
import Foundation
import PrismAgent

final class HomeViewModelImpl: HomeViewModel {
    @Published var profile = HomeState.Profile(
        profileImage: Data(),
        fullName: "Olivia Rhye"
    )
    @Published var lastActivities = [HomeState.ActivityLog]()

    private let agent: PrismAgent

    init(
        agent: PrismAgent
    ) {
        self.agent = agent

        bind()
    }

    private func bind() {
        lastActivities = []
    }
}
