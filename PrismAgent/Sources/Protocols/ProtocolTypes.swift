import Foundation

enum ProtocolTypes: String {
    case didcommMediationRequest = "https://didcomm.org/coordinate-mediation/2.0/mediate-request"
    case didcommMediationGrant = "https://didcomm.org/coordinate-mediation/2.0/mediate-grant"
    case didcommMediationDeny = "https://didcomm.org/coordinate-mediation/2.0/mediate-deny"
    case didcommMediationKeysUpdate = "https://didcomm.org/coordinate-mediation/2.0/keylist-update"
    case didcommPresentation = "https://didcomm.org/present-proof/2.0/presentation"
    case didcommRequestPresentation = "https://didcomm.org/present-proof/2.0/request-presentation"
    case didcommProposePresentation = "https://didcomm.org/present-proof/2.0/propose-presentation"
    case didcommCredentialPreview = "https://didcomm.org/issue-credential/2.0/credential-preview"
    case didcommIssueCredential = "https://didcomm.org/issue-credential/2.0/issue-credential"
    case didcommOfferCredential = "https://didcomm.org/issue-credential/2.0/offer-credential"
    case didcommProposeCredential = "https://didcomm.org/issue-credential/2.0/propose-credential"
    case didcommRequestCredential = "https://didcomm.org/issue-credential/2.0/request-credential"
    case didcommconnectionRequest = "https://atalaprism.io/mercury/connections/1.0/request"
    case didcommconnectionResponse = "https://atalaprism.io/mercury/connections/1.0/response"
    case didcomminvitation = "https://didcomm.org/out-of-band/2.0/invitation"
    case prismOnboarding = "https://atalaprism.io/did-request"
    case pickupRequest = "https://didcomm.org/messagepickup/3.0/delivery-request"
    case pickupDelivery = "https://didcomm.org/messagepickup/3.0/delivery"
    case pickupStatus = "https://didcomm.org/messagepickup/3.0/status"
    case pickupReceived = "https://didcomm.org/messagepickup/3.0/messages-received"
}
