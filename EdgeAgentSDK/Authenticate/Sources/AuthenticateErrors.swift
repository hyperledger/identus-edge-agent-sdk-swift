import Foundation

public enum AuthenticateError: Error {
    case cannotFindDeepLinkServiceError
    case invalidDeepLinkError
    case deepLinkNotAvailableError
    case urlNotAuthenticateServiceError
    case invalidSignatureError
    case challengeRefusedError
    case notSignableKey
}
