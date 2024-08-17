import Foundation

public protocol PresentationExchangeClaimVerifier {
    func verifyClaim(inputDescriptor: InputDescriptor) throws
}
