import PrismAgent
import Domain
import Foundation

final class SetupPrismAgentViewModelImpl: ObservableObject, SetupPrismAgentViewModel {

    @Published var status: String = ""
    @Published var mediatorRoutingId: String = ""

    private let agent: PrismAgent

    init() {
        let did = try! DID(string: "did:peer:2.Ez6LScc4S6tTSf5PnB7tWAna8Ee2aL7z2nRgo6aCHQwLds3m4.Vz6MktCyutFBcZcAWBnE2shqqUQDyRdnvcwqMTPqWsGHMnHyT.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwOi8vcm9vdHNpZC1tZWRpYXRvcjo4MDAwIiwiYSI6WyJkaWRjb21tL3YyIl19")

        let oob = "http://rootsid-mediator:8000?_oob=eyJ0eXBlIjoiaHR0cHM6Ly9kaWRjb21tLm9yZy9vdXQtb2YtYmFuZC8yLjAvaW52aXRhdGlvbiIsImlkIjoiMmZjNzQyYjktZTFmOS00ODJlLTkxMmItOGY5MDhhODVhYTYxIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNjYzRTNnRUU2Y1UG5CN3RXQW5hOEVlMmFMN3oyblJnbzZhQ0hRd0xkczNtNC5WejZNa3RDeXV0RkJjWmNBV0JuRTJzaHFxVVFEeVJkbnZjd3FNVFBxV3NHSE1uSHlULlNleUpwWkNJNkltNWxkeTFwWkNJc0luUWlPaUprYlNJc0luTWlPaUpvZEhSd09pOHZjbTl2ZEhOcFpDMXRaV1JwWVhSdmNqbzRNREF3SWl3aVlTSTZXeUprYVdSamIyMXRMM1l5SWwxOSIsImJvZHkiOnsiZ29hbF9jb2RlIjoicmVxdWVzdC1tZWRpYXRlIiwiZ29hbCI6IlJlcXVlc3RNZWRpYXRlIiwibGFiZWwiOiJNZWRpYXRvciIsImFjY2VwdCI6WyJkaWRjb21tL3YyIl19fQ"

        self.agent = PrismAgent(mediatorServiceEnpoint: did)
        status = agent.state.rawValue
    }

    func start() async throws {
        await MainActor.run {
            status = agent.state.rawValue
        }
        try await agent.start()
        await MainActor.run {
            status = agent.state.rawValue
            mediatorRoutingId = agent.connectionManager.mediator?.routingDID.string ?? ""
        }
    }
}
