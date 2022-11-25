import Foundation

enum ProtocolTypes: String {
    case didcommconnectionRequest = "https://atalaprism.io/mercury/connections/1.0/request"
    case didcommconnectionResponse = "https://atalaprism.io/mercury/connections/1.0/response"
    case didcomminvitation = "https://didcomm.org/out-of-band/2.0/invitation"
    case prismOnboarding = "https://atalaprism.io/did-request"
    case pickupRequest = "https://didcomm.org/messagepickup/3.0/delivery-request"
    case pickupDelivery = "https://didcomm.org/messagepickup/3.0/delivery"
}
