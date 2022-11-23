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
    case fromFieldNotSetError
    case unknownAttachmentDataError
    case messageAttachmentWithoutIDError
    case messageInvalidBodyDataError
    case unknowPackingMessageError
    case didcommError(msg: String)
}

public enum PlutoError: Error {
    case invalidHolderDIDNotPersistedError
    case messageMissingFromOrToDIDError
    case didPairIsNotPersistedError
    case holderDIDAlreadyPairingError
}

public enum PolluxError: Error {
    case invalidCredentialError
}
