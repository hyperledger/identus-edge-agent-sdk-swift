public enum PrismAgentError: Error {
    case invalidURLError
    case cannotFindDIDKeyPairIndex
    case invitationHasNoFromDIDError
    case noValidServiceEndpointError
    case invitationIsInvalidError
    case noConnectionOpenError
    case noHandshakeResponseError
    case unknownInvitationTypeError
    case unknownPrismOnboardingTypeError
    case failedToOnboardError
    case invalidPickupDeliveryMessageError
    case invalidOfferCredentialMessageError
    case invalidProposedCredentialMessageError
    case invalidIssueCredentialMessageError
    case invalidRequestCredentialMessageError
    case invalidPresentationMessageError
    case invalidRequestPresentationMessageError
    case invalidProposePresentationMessageError
    case invalidMediationGrantMessageError
    case noMediatorAvailableError
    case mediationRequestFailedError
    case invalidStepError
}
