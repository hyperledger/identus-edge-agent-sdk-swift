import Foundation

public enum CommonError: Error {
    case somethingWentWrongError
}

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
    case invalidJWKKeysError
    case invalidKeyError
    case invalidPeerDIDError
}

public enum MercuryError: Error {
    case invalidURLError
    case noDIDReceiverSetError
    case noValidServiceFoundError
    case fromFieldNotSetError
    case unknownAttachmentDataError
    case messageAttachmentWithoutIDError
    case messageInvalidBodyDataError
    case unknowPackingMessageError
    case couldNotResolveDIDError
    case didcommError(msg: String)
    case urlSessionError(statusCode: Int, error: Error?, msg: String?)
}

public enum PlutoError: Error {
    case invalidHolderDIDNotPersistedError
    case messageMissingFromOrToDIDError
    case didPairIsNotPersistedError
    case holderDIDAlreadyPairingError
    case unknownCredentialTypeError
    case invalidCredentialJsonError
}

public enum PolluxError: Error {
    case invalidCredentialError
    case invalidJWTString
}
