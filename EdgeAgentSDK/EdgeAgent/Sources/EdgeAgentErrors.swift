import Domain

/**
 An enum representing a known error in a Prism agent API response.

 - Note: When an error occurs during an API request/response cycle, the server may return an error object in the response. This object may include an error code and an error message. If the error received conforms to the `KnownPrismError` protocol, it will be classified as a known error.

 - SeeAlso: `UnknownPrismError`, `KnownPrismError`
 */
public enum EdgeAgentError: KnownPrismError {

    public enum OIDCError: KnownPrismError {
        /// An error case representing that a `CredentialOffer` doesnt contain grants.
        case noGrantProvided

        /// An error case representing that a flow is not supported.
        case flowNotSupported

        /// An error case representing an internal error normally originating from a library
        case internalError(error: Error)

        /// An error case representing an invalid callback url
        case invalidCallbackURL

        /// An error case representing that some parameters are missing from the callback url
        case missingQueryParameters(parameters: [String])

        /// An error case representing that a credential request cannot be of deferred type
        case crendentialResponseDeferredNotSupported

        /// An error case representing that an invalid proof was submited
        case invalidProof(errorDescription: String?)

        public var code: Int {
            switch self {
            case .noGrantProvided:
                return 1001
            case .flowNotSupported:
                return 1002
            case .internalError:
                return 1003
            case .invalidCallbackURL:
                return 1004
            case .missingQueryParameters:
                return 1005
            case .crendentialResponseDeferredNotSupported:
                return 1006
            case .invalidProof:
                return 1007
            }
        }

        public var message: String {
            switch self {
            case .noGrantProvided:
                return "No grant was provided"
            case .flowNotSupported:
                return "The flow is not supported"
            case .internalError(error: let error):
                return "An internal error occurred: \(error)"
            case .invalidCallbackURL:
                return "The callback url is invalid"
            case .missingQueryParameters(parameters: let parameters):
                return "The following query parameters are missing on the callback url: \(parameters)"
            case .crendentialResponseDeferredNotSupported:
                return "Credential response deferred is not supported"
            case .invalidProof(errorDescription: let errorDescription):
                return "The proof is invalid: \(errorDescription ?? "")"
            }
        }
    }

    /// An error case representing that a DID key pair index could not be found.
    case cannotFindDIDKeyPairIndex

    /// An error case representing that an invitation is invalid.
    case invitationIsInvalidError

    /// An error case representing an unknown invitation type.
    case unknownInvitationTypeError

    /// An error case representing an invalid message type.
    case invalidMessageType(type: String, shouldBe: [String])

    /// An error case representing that no mediator is available.
    case noMediatorAvailableError

    /// An error case representing that a mediation request has failed.
    case mediationRequestFailedError(underlyingErrors: [Error]?)

    /// An error case representing that a credential cannot issue presentations.
    case credentialCannotIssuePresentations

    /// An error case representing an invalid attachment format.
    case invalidAttachmentFormat(String?)

    /// An error case representing that a key requires to conform to the Exportable protocol.
    case keyIsNotExportable

    /// An error case representing that the wallet was not initialized and a Link secret is not set yet.
    case noLinkSecretConfigured


    /// The error code returned by the server.
    public var code: Int {
        switch self {
        case .cannotFindDIDKeyPairIndex:
            return 111
        case .invitationIsInvalidError:
            return 112
        case .unknownInvitationTypeError:
            return 113
        case .invalidMessageType:
            return 114
        case .noMediatorAvailableError:
            return 115
        case .mediationRequestFailedError:
            return 116
        case .credentialCannotIssuePresentations:
            return 117
        case .invalidAttachmentFormat:
            return 118
        case .keyIsNotExportable:
            return 117
        case .noLinkSecretConfigured:
            return 118

        }
    }

    /**
     The error message returned by the server.

     - Note: For this enum, the error message is determined based on the specific error case that was encountered.

     - SeeAlso: `cannotFindDIDKeyPairIndex`, `invitationIsInvalidError`, `unknownInvitationTypeError`, `invalidMessageType`, `noMediatorAvailableError`, `mediationRequestFailedError`
     */
    public var message: String {
        switch self {
        case .cannotFindDIDKeyPairIndex:
            return "To sign with a DID a key pair needs to be registered, please register the key pair first/"
        case .invitationIsInvalidError:
            return "The system could not parse the invitation, the message/json are invalid"
        case .unknownInvitationTypeError:
            return "The type of the invitation is not supported."
        case let .invalidMessageType(type, shouldBe):
            return """
The following message \(type), does not represent the protocol \(shouldBe).
Also the message should have \"from\" and \"to\" fields
"""
        case .noMediatorAvailableError:
            return """
There is no mediator.
You need to provide a mediation handler and start the prism agent before doing some operations.
"""
        case .mediationRequestFailedError(let underlyningErrors):
            let errorsMessages = underlyningErrors
                .map { $0.map { $0.localizedDescription } }?
                .joined(separator: ", ")
            let message = errorsMessages.map { "Errors: " + $0 } ?? ""
            return "Something failed while trying to achieve mediation. \(message)"
        case .credentialCannotIssuePresentations:
            return "Credential doesnt conform with proof protocol"
        case .invalidAttachmentFormat(let format):
            return "Attachment format is not supported \(format ?? "")"
        case .keyIsNotExportable:
            return "The key requires to conform to the Exportable protocol"
        case .noLinkSecretConfigured:
            return "The link secret was not initialized, please run start() once"
        }
    }
}

extension EdgeAgentError: Equatable {
    public static func == (lhs: EdgeAgentError, rhs: EdgeAgentError) -> Bool {
        lhs.message == rhs.message
    }
}
