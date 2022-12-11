import PrismAgent
import Combine
import Domain
import Foundation

final class SetupPrismAgentViewModelImpl: ObservableObject, SetupPrismAgentViewModel {

    @Published var status: String = ""
    @Published var error: String?

    private let agent: PrismAgent
    private var cancellables = [AnyCancellable]()

    init() {
        let did = try! DID(string: "did:peer:2.Ez6LSms555YhFthn1WV8ciDBpZm86hK9tp83WojJUmxPGk1hZ.Vz6MkmdBjMyB4TS5UbbQw54szm8yvMMf1ftGV2sQVYAxaeWhE.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwczovL21lZGlhdG9yLnJvb3RzaWQuY2xvdWQiLCJhIjpbImRpZGNvbW0vdjIiXX0")

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
        let url = "https://domain.com/path?_oob=eyJpZCI6IjhkYzY3MTRjLTJiNmEtNGZkOS1iYzg3LWJiODhlYTk1NmFiNyIsInR5cGUiOiJodHRwczovL2RpZGNvbW0ub3JnL291dC1vZi1iYW5kLzIuMC9pbnZpdGF0aW9uIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNxQWlIZWRIRmZiZW14UnpyUjV0ZTQ2VUdzdHhkcW0yMXpFelVjd3dGaVhwcC5WejZNa2ljRWh6NHRoQlZMWVRlc3VEWkJOOTdLRTdoTHdYRVR0UWppajJrcWl3N3Q0LlNleUowSWpvaVpHMGlMQ0p6SWpvaWFIUjBjRG92TDJodmMzUXVaRzlqYTJWeUxtbHVkR1Z5Ym1Gc09qZ3dPREF2Wkdsa1kyOXRiU0lzSW5JaU9sdGRMQ0poSWpwYkltUnBaR052YlcwdmRqSWlYWDAiLCJib2R5Ijp7ImdvYWxfY29kZSI6ImNvbm5lY3QiLCJnb2FsIjoiRXN0YWJsaXNoIGEgdHJ1c3QgY29ubmVjdGlvbiBiZXR3ZWVuIHR3byBwZWVycyIsImFjY2VwdCI6W119fQ=="

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

    func startMessageStream() async throws {
        agent.startFetchingMessages()
        agent.handleMessagesEvents().sink {
            switch $0 {
            case .finished:
                print("Finished message retrieval")
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: {
            print("Received message: \($0.id)")
        }
        .store(in: &cancellables)
    }
}
