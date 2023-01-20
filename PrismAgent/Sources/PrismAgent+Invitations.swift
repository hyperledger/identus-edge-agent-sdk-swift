import Domain
import Foundation

// MARK: Invitation funcionalities
public extension PrismAgent {
    /// Enumeration representing the type of invitation
    enum InvitationType {
        /// Struct representing a Prism Onboarding invitation
        public struct PrismOnboarding {
            /// Sender of the invitation
            public let from: String
            /// Onboarding endpoint
            public let endpoint: URL
            /// The own DID of the user
            public let ownDID: DID
        }

        /// Case representing a Prism Onboarding invitation
        case onboardingPrism(PrismOnboarding)
        /// Case representing a DIDComm Out-of-Band invitation
        case onboardingDIDComm(OutOfBandInvitation)
    }

    /// Parses the given string as an invitation
    /// - Parameter str: The string to parse
    /// - Returns: The parsed invitation
    /// - Throws: `PrismAgentError` if the invitation is not a valid Prism or OOB type
    func parseInvitation(str: String) async throws -> InvitationType {
        if let prismOnboarding = try? await parsePrismInvitation(str: str) {
            return .onboardingPrism(prismOnboarding)
        } else if let message = try? parseOOBInvitation(url: str) {
            return .onboardingDIDComm(message)
        }
        throw PrismAgentError.unknownInvitationTypeError
    }

    /// Parses the given string as a Prism Onboarding invitation
    /// - Parameter str: The string to parse
    /// - Returns: The parsed Prism Onboarding invitation
    /// - Throws: `PrismAgentError` if the string is not a valid Prism Onboarding invitation
    func parsePrismInvitation(
        str: String
    ) async throws -> InvitationType.PrismOnboarding {
        let prismOnboarding = try PrismOnboardingInvitation(jsonString: str)
        guard
            let url = URL(string: prismOnboarding.body.onboardEndpoint)
        else { throw PrismAgentError.invalidURLError }

        let ownDID = try await createNewPeerDID(
            services: [.init(
                id: "#didcomm-1",
                type: ["DIDCommMessaging"],
                serviceEndpoint: .init(
                    uri: "https://localhost:8080/didcomm"
                ))
            ],
            updateMediator: false
        )

        return .init(
            from: prismOnboarding.body.from,
            endpoint: url,
            ownDID: ownDID
        )
    }

    /// Parses the given string as an Out-of-Band invitation
    /// - Parameter url: The string to parse
    /// - Returns: The parsed Out-of-Band invitation
    /// - Throws: `PrismAgentError` if the string is not a valid URL
    func parseOOBInvitation(url: String) throws -> OutOfBandInvitation {
        guard let url = URL(string: url) else { throw PrismAgentError.invalidURLError }
        return try parseOOBInvitation(url: url)
    }

    /// Parses the given URL as an Out-of-Band invitation
    /// - Parameter url: The URL to parse
    /// - Returns: The parsed Out-of-Band invitation
    /// - Throws: `PrismAgentError` if the URL is not a valid Out-of-Band invitation
    func parseOOBInvitation(url: URL) throws -> OutOfBandInvitation {
        return try DIDCommInvitationRunner(url: url).run()
    }

    /// Accepts an Out-of-Band (DIDComm) invitation and establishes a new connection
    /// - Parameter invitation: The Out-of-Band invitation to accept
    /// - Throws: `PrismAgentError` if there is no mediator available or other errors occur during the acceptance process
    func acceptDIDCommInvitation(invitation: OutOfBandInvitation) async throws {
        guard let mediatorRoutingDID else { throw PrismAgentError.noMediatorAvailableError }
        logger.info(message: "Start accept DIDComm invitation")
        let ownDID = try await createNewPeerDID(
            services: [.init(
                id: "#didcomm-1",
                type: ["DIDCommMessaging"],
                serviceEndpoint: .init(
                    uri: mediatorRoutingDID.string
                ))
            ],
            updateMediator: true
        )

        logger.info(message: "Sending DIDComm Connection message")

        let pair = try await DIDCommConnectionRunner(
            invitationMessage: invitation,
            pluto: pluto,
            ownDID: ownDID,
            connection: connectionManager
        ).run()
        try await connectionManager.addConnection(pair)
    }

    /// Accepts a Prism Onboarding invitation and performs the onboarding process
    /// - Parameter invitation: The Prism Onboarding invitation to accept
    /// - Throws: `PrismAgentError` if the onboarding process fails
    func acceptPrismInvitation(invitation: InvitationType.PrismOnboarding) async throws {
        struct SendDID: Encodable {
            let did: String
        }
        var request = URLRequest(url: invitation.endpoint)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(SendDID(did: invitation.ownDID.string))
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        let response = try await URLSession.shared.data(for: request)
        guard
            let urlResponse = response.1 as? HTTPURLResponse,
            urlResponse.statusCode == 200
        else { throw PrismAgentError.failedToOnboardError }
    }
}
