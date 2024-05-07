import EdgeAgent
import Builders
import Combine
import Domain
import Foundation

final class SetupEdgeAgentViewModelImpl: ObservableObject, SetupEdgeAgentViewModel {

    @Published var oobUrl: String = "https://domain.com/path?_oob=eyJpZCI6ImNjZmM0MjYyLTczZjItNGFkMy1iYWVhLTgwNmQ0MjNkZjQ5NyIsInR5cGUiOiJodHRwczovL2RpZGNvbW0ub3JnL291dC1vZi1iYW5kLzIuMC9pbnZpdGF0aW9uIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNmTTlGYVp1a0JDR3hVVlpLVkN4RlRrb1BZcW00dkxCbm9XN202R1E1dlBUOC5WejZNa3FUOWV2NmU3Wm5xVlM2OUZ5d3ZUQkVpdG41SGNQeFRkVzVTYmFkdzZtTWY3LlNleUowSWpvaVpHMGlMQ0p6SWpvaWFIUjBjRG92TDJ4dlkyRnNhRzl6ZERvNU1ERXdMMlJwWkdOdmJXMGlMQ0p5SWpwYlhTd2lZU0k2V3lKa2FXUmpiMjF0TDNZeUlsMTkiLCJib2R5Ijp7ImdvYWxfY29kZSI6ImlvLmF0YWxhcHJpc20uY29ubmVjdCIsImdvYWwiOiJFc3RhYmxpc2ggYSB0cnVzdCBjb25uZWN0aW9uIGJldHdlZW4gdHdvIHBlZXJzIHVzaW5nIHRoZSBwcm90b2NvbCAnaHR0cHM6Ly9hdGFsYXByaXNtLmlvL21lcmN1cnkvY29ubmVjdGlvbnMvMS4wL3JlcXVlc3QnIiwiYWNjZXB0IjpbXX19"
    @Published var status: String = ""
    @Published var error: String?

    private let agent: EdgeAgent
    private var cancellables = [AnyCancellable]()

    init() {
        let did = try! DID(string: "did:peer:2.Ez6LSms555YhFthn1WV8ciDBpZm86hK9tp83WojJUmxPGk1hZ.Vz6MkmdBjMyB4TS5UbbQw54szm8yvMMf1ftGV2sQVYAxaeWhE.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwczovL21lZGlhdG9yLnJvb3RzaWQuY2xvdWQiLCJhIjpbImRpZGNvbW0vdjIiXX0")

        self.agent = EdgeAgent(mediatorDID: did)
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
            let message = try agent.parseOOBInvitation(url: oobUrl)
            try await agent.acceptDIDCommInvitation(invitation: message)
        } catch let error as CommonError {
            switch error {
            case let .httpError(_, message):
                print("Error: \(message)")
            default:
                break
            }
        } catch let error as LocalizedError {
            print("Error: \(error.errorDescription)")
        }
    }

    func startMessageStream() {
        agent.startFetchingMessages()
        agent.handleReceivedMessagesEvents().sink {
            switch $0 {
            case .finished:
                print("Finished message retrieval")
            case .failure(let error):
                self.error = error.localizedDescription
            }
        } receiveValue: { message -> () in
            do {
                if let issued = try? IssueCredential(fromMessage: message) {
                    _ = try issued.attachments.compactMap {
                        switch $0.data {
                        case let data as AttachmentBase64:
                            break
                        default:
                            return
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
        .store(in: &cancellables)
    }

    func startIssueCredentialProtocol() async {
        // TODO: This needs to be redone.
//        do {
//            try await agent.issueCredentialProtocol()
//        } catch let error as MercuryError {
//            switch error {
//            case let .urlSessionError(statusCode, error, msg):
//                print("Error: \(statusCode)")
//            case let .didcommError(msg):
//                if msg.contains("Invalid state") {
//                    print("")
//                }
//                print("Error: \(msg)")
//            default:
//                break
//            }
//            if error.localizedDescription.contains("Invalid state") {
//                print("")
//            }
//            print("Error: \(error.localizedDescription)")
//        } catch {
//            await MainActor.run {
//                self.error = error.localizedDescription
//                print(error.localizedDescription)
//            }
//        }
//        print("Finished")
    }
}
