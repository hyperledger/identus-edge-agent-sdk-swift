import PrismAgent
import Combine
import Domain
import Foundation

final class SetupPrismAgentViewModelImpl: ObservableObject, SetupPrismAgentViewModel {

    @Published var oobUrl: String = "https://domain.com/path?_oob=eyJpZCI6IjA3MTViZGE5LTI5NzctNGFhMS1iOTQ2LWJkMWMwMTFiNDcwMCIsInR5cGUiOiJodHRwczovL2RpZGNvbW0ub3JnL291dC1vZi1iYW5kLzIuMC9pbnZpdGF0aW9uIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNua0h4Rm54NUIzZWRxaVpkanN1RkRhS1Raa05iUkVVNWJKWkw4d29YQnVFQS5WejZNa3JiV3UzSFplMVRMbWo5U2FnaVpCazZrTUIzcEJmYWZOUE5OaDRNNzVOemhYLlNleUowSWpvaVpHMGlMQ0p6SWpvaWFIUjBjRG92TDJodmMzUXVaRzlqYTJWeUxtbHVkR1Z5Ym1Gc09qZ3dPREF2Wkdsa1kyOXRiU0lzSW5JaU9sdGRMQ0poSWpwYkltUnBaR052YlcwdmRqSWlYWDAiLCJib2R5Ijp7ImdvYWxfY29kZSI6ImNvbm5lY3QiLCJnb2FsIjoiRXN0YWJsaXNoIGEgdHJ1c3QgY29ubmVjdGlvbiBiZXR3ZWVuIHR3byBwZWVycyIsImFjY2VwdCI6W119fQ=="
    @Published var status: String = ""
    @Published var error: String?

    private let agent: PrismAgent
    private var cancellables = [AnyCancellable]()

    init() {
        let did = try! DID(string: "did:peer:2.Ez6LShi7LMpR9aGFpyTqT6f5bZNFVdjspH61WPneaMEEhNZxh.Vz6MkhSEtgAWDcpL33sZiQsVr2bJG7Z7HbLoF5Ta7R8Tbk8G9.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwOi8vcm9vdHNpZC1tZWRpYXRvcjo4MDAwIiwiYSI6WyJkaWRjb21tL3YyIl19")

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
//            try await agent.awaitMessages()
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }

    func parseOOBMessage() async throws {
        do {
            let message = try await agent.parseOOBInvitation(url: oobUrl)
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

    func startMessageStream() {
        agent.startFetchingMessages()
        agent.handleMessagesEvents().sink {
            switch $0 {
            case .finished:
                print("Finished message retrieval")
            case .failure(let error):
                self.error = error.localizedDescription
            }
        } receiveValue: {
            print("Received message: \($0.id)")
        }
        .store(in: &cancellables)
    }
}
