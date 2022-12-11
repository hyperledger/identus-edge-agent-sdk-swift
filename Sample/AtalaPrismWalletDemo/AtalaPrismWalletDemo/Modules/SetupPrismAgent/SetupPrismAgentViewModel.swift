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
            try await agent.awaitMessages()
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }

    func parseOOBMessage() async throws {
        let url = "https://domain.com/path?_oob=eyJpZCI6ImU0ZGRlNWVkLTczMWQtNDQ2Ni1iMTVhLTJjMzBhMTFlZjU3MSIsInR5cGUiOiJodHRwczovL2RpZGNvbW0ub3JnL291dC1vZi1iYW5kLzIuMC9pbnZpdGF0aW9uIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNjdVJuYlpBSmFWdGhjTDVSRUxxNzVFQksyc0JtQnhzU3M5OExLTmVyaUhRSi5WejZNa3BlYVc3RGVwdEpXN3BpMnFOWFRkQ1hlUVY0RVlwWm5Bb3VIMUxyZkhqNnVmLlNleUowSWpvaVpHMGlMQ0p6SWpvaWFIUjBjSE02THk5ck9ITXRaR1YyTG1GMFlXeGhjSEpwYzIwdWFXOHZjSEpwYzIwdFlXZGxiblF2Wkdsa1kyOXRiU0lzSW5JaU9sdGRMQ0poSWpwYkltUnBaR052YlcwdmRqSWlYWDAiLCJib2R5Ijp7ImdvYWxfY29kZSI6ImNvbm5lY3QiLCJnb2FsIjoiRXN0YWJsaXNoIGEgdHJ1c3QgY29ubmVjdGlvbiBiZXR3ZWVuIHR3byBwZWVycyIsImFjY2VwdCI6W119fQ=="

        do {
            let message = try await agent.parseOOBInvitation(url: url)
            try await agent.acceptDIDCommInvitation(invitation: message)
        } catch let error as MercuryError {
            switch error {
            case let .urlSessionError(statusCode, error, msg):
                print("Error: \(statusCode)")
            default:
                break
            }
        }
    }
}
