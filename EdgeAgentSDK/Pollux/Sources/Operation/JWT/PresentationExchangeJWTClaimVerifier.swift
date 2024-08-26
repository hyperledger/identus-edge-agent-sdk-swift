import Domain
import Foundation
import JSONWebToken

struct JWTVerifierPresentationExchange: PresentationExchangeClaimVerifier {
    let castor: Castor
    let jwtString: String
    let submissionDescriptor: PresentationSubmission.Descriptor

    func verifyClaim(inputDescriptor: InputDescriptor) throws {
        let payload = try JWT.getPayload(jwtString: jwtString)
        try VerifyJsonClaim.verify(inputDescriptor: inputDescriptor, jsonData: payload)
    }
}
