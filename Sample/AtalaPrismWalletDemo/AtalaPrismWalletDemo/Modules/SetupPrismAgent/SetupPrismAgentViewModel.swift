import PrismAgent
import Builders
import Combine
import Domain
import Foundation
import SwiftJWT

final class SetupPrismAgentViewModelImpl: ObservableObject, SetupPrismAgentViewModel {

    @Published var oobUrl: String = "https://domain.com/path?_oob=eyJpZCI6IjlmMDBkMTg1LWEwZGQtNDcyNy1iY2I1LWQwMTc0NmIwYWNkNCIsInR5cGUiOiJodHRwczovL2RpZGNvbW0ub3JnL291dC1vZi1iYW5kLzIuMC9pbnZpdGF0aW9uIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNmdVhkcDRybmNwQnZxanlXYVE1Z1IxWHB3dFVHbzZVYmpmQ3lINldKYzhCbi5WejZNa29ZUWRoVm1rSEthVGhZU1ZSOFRvYzVkZWp1ZW0yTENzWDRlU280WHRYQ1ZDLlNleUowSWpvaVpHMGlMQ0p6SWpvaWFIUjBjRG92TDJodmMzUXVaRzlqYTJWeUxtbHVkR1Z5Ym1Gc09qZ3dPREF2Wkdsa1kyOXRiU0lzSW5JaU9sdGRMQ0poSWpwYkltUnBaR052YlcwdmRqSWlYWDAiLCJib2R5Ijp7ImdvYWxfY29kZSI6ImNvbm5lY3QiLCJnb2FsIjoiRXN0YWJsaXNoIGEgdHJ1c3QgY29ubmVjdGlvbiBiZXR3ZWVuIHR3byBwZWVycyIsImFjY2VwdCI6W119fQ=="
    @Published var status: String = ""
    @Published var error: String?

    private let agent: PrismAgent
    private var cancellables = [AnyCancellable]()

    init() {
        let did = try! DID(string: "did:peer:2.Ez6LSms555YhFthn1WV8ciDBpZm86hK9tp83WojJUmxPGk1hZ.Vz6MkmdBjMyB4TS5UbbQw54szm8yvMMf1ftGV2sQVYAxaeWhE.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwczovL21lZGlhdG9yLnJvb3RzaWQuY2xvdWQiLCJhIjpbImRpZGNvbW0vdjIiXX0")

        self.agent = PrismAgent(mediatorDID: did)
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
                            let b64 = Data(base64URLEncoded: data.base64)!
                            let str = String(data: b64, encoding: .utf8)!
                            let apollo = ApolloBuilder().build()
                            let castor = CastorBuilder(apollo: apollo).build()
                            let pollux = PolluxBuilder(castor: castor).build()
                            let credential = try pollux.parseVerifiableCredential(jwtString: str)
                            print(credential)
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
