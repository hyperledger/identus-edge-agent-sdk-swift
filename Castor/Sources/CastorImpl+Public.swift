import Domain

extension CastorImpl: Castor {
    public func parseDID(str: String) throws -> DID {
        try DIDParser(didString: str).parse()
    }
}
