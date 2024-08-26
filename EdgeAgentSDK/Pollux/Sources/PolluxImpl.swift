import Combine
import Domain

public struct PolluxImpl {
    let pluto: Pluto
    let castor: Castor
    let presentationExchangeParsers: [SubmissionDescriptorFormatParser]
    public init(
        castor: Castor,
        pluto: Pluto,
        presentationExchangeParsers: [SubmissionDescriptorFormatParser]
    ) {
        self.pluto = pluto
        self.castor = castor
        self.presentationExchangeParsers = presentationExchangeParsers
    }

    public init(castor: Castor, pluto: Pluto) {
        self.init(
            castor: castor,
            pluto: pluto,
            presentationExchangeParsers: [
                JWTPresentationExchangeParser(verifier: .init(castor: castor)),
                JWTVCPresentationExchangeParser(verifier: .init(castor: castor)),
                JWTVPPresentationExchangeParser(verifier: .init(castor: castor)),
                SDJWTPresentationExchangeParser(verifier: .init(castor: castor))
            ]
        )
    }
}
