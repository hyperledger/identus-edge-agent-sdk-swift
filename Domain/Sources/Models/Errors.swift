import Foundation

public enum ApolloError: Error {
    case invalidMnemonicWord
    case couldNotParseMessageString
}

public enum CastorError: Error {
    case invalidLongFormDID
    case methodIdIsDoesNotSatisfyRegex
    case invalidPublicKeyEncoding
    case invalidDIDString
    case initialStateOfDIDChanged
    case notPossibleToResolveDID
}

public enum MercuryError: Error {
    case invalidURLError
    case noDIDReceiverSetError
    case noValidServiceFoundError
}
