import Builders
import Domain
import Foundation
import PrismAgent

final class SigningVerificationViewModel: ObservableObject {
    private let castor: Castor
    private let agent: PrismAgent

    init() {
        self.castor = CastorBuilder(
            apollo: ApolloBuilder().build()
        ).build()
        self.agent = PrismAgent(mediatorDID: DID(method: "peer", methodId: "1234"))
    }

    @Published var createdDID: DID?
    @Published var message: String = ""
    @Published var signedMessage: Signature?
    @Published var verifiedMessage: Bool?

    func createPrismDID() async {

        // Creates new PRISM DID
        let did = try? await agent.createNewPrismDID(
            // Add this if you want to provide a IndexPath
            // keyPathIndex: <#T##Int?#>
            // Add this if you want to provide an alias for this DID
            // alias: <#T##String?#>
            // Add any services available in the DID
            services: [ .init(
                id: "DemoID",
                type: ["DemoType"],
                serviceEndpoint: .init(uri: "DemoServiceEndpoint")
            )
       ])
        await MainActor.run {
            self.createdDID = did
            self.verifiedMessage = nil
        }
    }

    func signMessageWithDID() async {
        guard
            let did = createdDID,
            let messageData = message.data(using: .utf8)
        else { return }

        // Signs with a valid DID that was created by the agent
        let signature = try? await agent.signWith(did: did, message: messageData)
        await MainActor.run {
            self.signedMessage = signature
        }
    }

    func verifyMessage() async {
        guard
            let did = createdDID,
            let messageData = message.data(using: .utf8),
            let signedMessage
        else { return }

        // Verifies a message signature given a DID
        let verifiedMessage = try? await castor.verifySignature(did: did, challenge: messageData, signature: signedMessage.value)
        await MainActor.run {
            self.verifiedMessage = verifiedMessage
        }
    }
}

extension Signature: ReflectedStringConvertible {}
