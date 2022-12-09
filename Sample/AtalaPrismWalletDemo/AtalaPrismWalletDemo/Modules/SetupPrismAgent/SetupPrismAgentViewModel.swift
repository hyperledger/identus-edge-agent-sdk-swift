import PrismAgent
import Domain
import Foundation

final class SetupPrismAgentViewModelImpl: ObservableObject, SetupPrismAgentViewModel {

    @Published var status: String = ""
    @Published var error: String?

    private let agent: PrismAgent

    init() {
        let did = try! DID(string: "did:peer:2.Ez6LScc4S6tTSf5PnB7tWAna8Ee2aL7z2nRgo6aCHQwLds3m4.Vz6MktCyutFBcZcAWBnE2shqqUQDyRdnvcwqMTPqWsGHMnHyT.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwOi8vcm9vdHNpZC1tZWRpYXRvcjo4MDAwIiwiYSI6WyJkaWRjb21tL3YyIl19")

        self.agent = PrismAgent(mediatorServiceEnpoint: did)
        status = agent.state.rawValue
    }

    func start() async throws {
        await MainActor.run {
            status = agent.state.rawValue
        }
        do {
            try await agent.start()
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
        await MainActor.run {
            status = agent.state.rawValue
        }
    }

    func updateKeyList() async throws {
        do {
            _ = try await agent.createNewPeerDID(updateMediator: true)
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
}
