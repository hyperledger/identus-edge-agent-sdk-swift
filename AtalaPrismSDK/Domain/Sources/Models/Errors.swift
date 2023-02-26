import Foundation

/**
 A protocol representing an unknown error in a Prism API response.

 - Note: When an error occurs during an API request/response cycle, the server may return an error object in the response. This object may include an error code, an error message, and possibly an array of underlying errors. If the error received does not conform to the `KnownPrismError` protocol, it will be classified as an `UnknownPrismError`.

 - SeeAlso: `KnownPrismError`
 */
public protocol UnknownPrismError: Error {
    /// The error code returned by the server.
    var code: Int? { get }

    /// The error message returned by the server.
    var message: String? { get }

    /// An array of underlying errors that may have contributed to this error.
    var underlyingErrors: [Error]? { get }
}

/**
 A protocol representing a known error in a Prism API response.

 - Note: When an error occurs during an API request/response cycle, the server may return an error object in the response. This object may include an error code and an error message. If the error received conforms to the `KnownPrismError` protocol, it will be classified as a known error.

 - SeeAlso: `UnknownPrismError`
 */
public protocol KnownPrismError: LocalizedError {
    /// The error code returned by the server.
    var code: Int { get }

    /// The error message returned by the server.
    var message: String { get }
}

/**
 An enum representing an unknown error in a Prism API response.

 - Note: When an error occurs during an API request/response cycle, the server may return an error object in the response. This object may include an error code, an error message, and possibly an array of underlying errors. If the error received does not conform to the `KnownPrismError` protocol, it will be classified as an `UnknownPrismError`.

 - SeeAlso: `UnknownPrismError`, `KnownPrismError`
 */
public enum UnknownError: UnknownPrismError {

    /**
     An error case representing a generic "something went wrong" error.

     - Parameters:
        - customMessage: A custom error message, if provided.
        - underlyingErrors: An array of underlying errors that may have contributed to this error, if provided.
     */
    case somethingWentWrongError(customMessage: String? = nil, underlyingErrors: [Error]? = nil)

    /// The error code returned by the server. In this case, the code is always -1.
    public var code: Int? { return -1 }

    /**
     The error message returned by the server.

     - Note: For this enum, the error message will either be a custom message provided at initialization or the default message "Something Went Wrong".

     - SeeAlso: `somethingWentWrongError(customMessage:underlyingErrors:)`
     */
    public var message: String? {
        switch self {
        case let .somethingWentWrongError(customMessage, _):
            return customMessage ?? "Something Went Wrong"
        }
    }

    /**
     An array of underlying errors that may have contributed to this error.

     - Note: For this enum, the array of underlying errors is determined at initialization and returned as-is.

     - SeeAlso: `somethingWentWrongError(customMessage:underlyingErrors:)`
     */
    public var underlyingErrors: [Error]? {
        switch self {
        case let .somethingWentWrongError(_, errors):
            return errors
        }
    }
}

extension UnknownError: Equatable {
    public static func == (lhs: UnknownError, rhs: UnknownError) -> Bool {
        switch (lhs, rhs) {
        case (.somethingWentWrongError, .somethingWentWrongError):
            return lhs.message == rhs.message && lhs.code == rhs.code
        }
    }
}

/**
 An enum representing a known error in a Prism API response.

 - Note: When an error occurs during an API request/response cycle, the server may return an error object in the response. This object may include an error code and an error message. If the error received conforms to the `KnownPrismError` protocol, it will be classified as a known error.

 - SeeAlso: `UnknownPrismError`, `KnownPrismError`
 */
public enum CommonError: KnownPrismError {

    /**
     An error case representing an invalid URL when attempting to send a message.

     - Parameters:
        - url: The invalid URL that caused the error.
     */
    case invalidURLError(url: String)

    /**
     An error case representing an HTTP error returned by the server.

     - Parameters:
        - code: The HTTP error code returned by the server.
        - message: The HTTP error message returned by the server.
     */
    case httpError(code: Int, message: String)

    /// The error code returned by the server.
    public var code: Int {
        switch self {
        case .invalidURLError:
            return -2
        case let .httpError(code, _):
            return code
        }
    }

    /**
     The error message returned by the server.

     - Note: For this enum, the error message is determined based on the specific error case that was encountered.

     - SeeAlso: `invalidURLError(url:)`, `httpError(code:message:)`
     */
    public var message: String {
        switch self {
        case .invalidURLError(let url):
            return "Invalid url while trying to send message: \(url)"
        case let .httpError(_, message):
            return message
        }
    }
}

extension CommonError: Equatable {
    public static func == (lhs: CommonError, rhs: CommonError) -> Bool {
        lhs.message == rhs.message
    }
}

/**
 An enum representing a known error in a Prism API response.

 - Note: When an error occurs during an API request/response cycle, the server may return an error object in the response. This object may include an error code and an error message. If the error received conforms to the `KnownPrismError` protocol, it will be classified as a known error.

 - SeeAlso: `KnownPrismError`
 */
public enum ApolloError: KnownPrismError {

    /**
     An error case representing invalid mnemonic words.

     - Parameters:
        - invalidWords: An array of invalid mnemonic words that caused the error.
     */
    case invalidMnemonicWord(invalidWords: [String])

    /**
     An error case representing a failure to parse a message string.

     - Note: This error occurs when attempting to convert a message string to UTF8 data.

     - SeeAlso: `Data(_:).utf8`
     */
    case couldNotParseMessageString

    /// An error case representing an invalid JWK format.
    case invalidJWKError

    /// The error code returned by the server.
    public var code: Int {
        switch self {
        case .invalidMnemonicWord:
            return 11
        case .couldNotParseMessageString:
            return 12
        case .invalidJWKError:
            return 13
        }
    }

    /**
     The error message returned by the server.

     - Note: For this enum, the error message is determined based on the specific error case that was encountered.

     - SeeAlso: `invalidMnemonicWord(invalidWords:)`, `couldNotParseMessageString`, `invalidJWKError`
     */
    public var message: String {
        switch self {
        case .invalidMnemonicWord(let words):
            return "The following mnemonic words are invalid: \(words.joined(separator: ","))"
        case .couldNotParseMessageString:
            return "Could not get UTF8 Data from message string"
        case .invalidJWKError:
            return "JWK is not in a valid format"
        }
    }
}

extension ApolloError: Equatable {
    public static func == (lhs: ApolloError, rhs: ApolloError) -> Bool {
        lhs.message == rhs.message
    }
}

/**
 An enum representing a known error in a Prism API response.

 - Note: When an error occurs during an API request/response cycle, the server may return an error object in the response. This object may include an error code and an error message. If the error received conforms to the `KnownPrismError` protocol, it will be classified as a known error.

 - SeeAlso: `UnknownPrismError`, `KnownPrismError`
 */
public enum CastorError: KnownPrismError {

    /**
     An error case representing an unsupported key curve.

     - Parameters:
        - curve: The unsupported key curve that caused the error.
     */
    case keyCurveNotSupported(curve: String)

    /// An error case representing an invalid long form DID.
    case invalidLongFormDID

    /**
     An error case representing a DID method ID that does not satisfy a regex pattern.

     - Parameters:
        - regex: The regex pattern that the DID method ID does not satisfy.
     */
    case methodIdIsDoesNotSatisfyRegex(regex: String)

    /**
     An error case representing invalid encoding/decoding of a public key while computing a DID.

     - Parameters:
        - didMethod: The DID method being computed.
        - curve: The key curve that was invalidly encoded/decoded.
     */
    case invalidPublicKeyCoding(didMethod: String, curve: String)

    /**
     An error case representing an invalid DID string.

     - Parameters:
        - str: The invalid DID string that caused the error.
     */
    case invalidDIDString(String)

    /// An error case representing a change in the initial state of a DID.
    case initialStateOfDIDChanged

    /**
     An error case representing the inability to resolve a DID.

     - Parameters:
        - did: The DID that could not be resolved.
        - reason: The reason why the DID could not be resolved.
     */
    case notPossibleToResolveDID(did: String, reason: String)

    /// An error case representing an invalid JWK format.
    case invalidJWKError

    /**
     An error case representing a lack of available resolvers for a given DID method.

     - Parameters:
        - method: The DID method that has no available resolvers.
     */
    case noResolversAvailableForDIDMethod(method: String)

    /// The error code returned by the server.
    public var code: Int {
        switch self {
        case .keyCurveNotSupported:
            return 21
        case .invalidLongFormDID:
            return 22
        case .methodIdIsDoesNotSatisfyRegex:
            return 23
        case .invalidPublicKeyCoding:
            return 24
        case .invalidDIDString:
            return 25
        case .initialStateOfDIDChanged:
            return 26
        case .notPossibleToResolveDID:
            return 27
        case .invalidJWKError:
            return 28
        case .noResolversAvailableForDIDMethod:
            return 29
        }
    }

    /**
     The error message returned by the server.

     - Note: For this enum, the error message is determined based on the specific error case that was encountered.

     - SeeAlso: `keyCurveNotSupported(curve:)`, `invalidLongFormDID`, `methodIdIsDoesNotSatisfyRegex(regex:)`, `invalidPublicKeyCoding(didMethod:curve:)`, `invalidDIDString(String)`, `initialStateOfDIDChanged`, `notPossibleToResolveDID(did:reason:)`, `invalidJWK`
     */
    public var message: String {
        switch self {
        case .keyCurveNotSupported(let curve):
            return "Key curve \(curve) is not supported for this funcionality"
        case .invalidLongFormDID:
            return "Long form prism DID is invalid or changed"
        case .methodIdIsDoesNotSatisfyRegex(let regex):
            return "The Prism DID provided is not passing the regex validation: \(regex)"
        case let .invalidPublicKeyCoding(didMethod, curve):
            return "Invalid encoding/decoding of key (\(curve)) while trying to compute \(didMethod)"
        case .invalidDIDString(let str):
            return "Trying to parse invalid DID String: \(str)"
        case .initialStateOfDIDChanged:
            return "While trying to resolve Prism DID state changed making it invalid"
        case let .notPossibleToResolveDID(did, reason):
            return "Not possible to resolve DID (\(did)) due to \(reason)"
        case .invalidJWKError:
            return "JWK is not in a valid format"
        case .noResolversAvailableForDIDMethod(let method):
            return "No resolvers in castor are able to resolve the method \(method), please provide a resolver"
        }
    }
}

extension CastorError: Equatable {
    public static func == (lhs: CastorError, rhs: CastorError) -> Bool {
        lhs.message == rhs.message
    }
}

/**
 An enum representing a known error in a Prism API response.

 - Note: When an error occurs during an API request/response cycle, the server may return an error object in the response. This object may include an error code and an error message. If the error received conforms to the `KnownPrismError` protocol, it will be classified as a known error.

 - SeeAlso: `UnknownPrismError`, `KnownPrismError`
 */
public enum MercuryError: KnownPrismError {

    /// An error case representing the lack of a recipient DID in a message.
    case noRecipientDIDSetError

    /**
     An error case representing the lack of valid services for a DID.

     - Parameters:
        - did: The DID that has no valid services.
     */
    case noValidServiceFoundError(did: String)

    /// An error case representing the lack of a sender DID in a message.
    case noSenderDIDSetError

    /// An error case representing an unknown attachment data type.
    case unknownAttachmentDataTypeError

    /// An error case representing a message attachment without an ID.
    case messageAttachmentWithoutIDError

    /// An error case representing invalid body data in a message.
    case messageInvalidBodyDataError

    /**
     An error case representing a DIDComm error.

     - Parameters:
        - msg: The message describing the error.
     */
    case didcommError(msg: String)

    /// The error code returned by the server.
    public var code: Int {
        switch self {
        case .noRecipientDIDSetError:
            return 31
        case .noValidServiceFoundError:
            return 32
        case .noSenderDIDSetError:
            return 33
        case .unknownAttachmentDataTypeError:
            return 34
        case .messageAttachmentWithoutIDError:
            return 35
        case .messageInvalidBodyDataError:
            return 36
        case .didcommError:
            return 37
        }
    }

    /**
     The error message returned by the server.

     - Note: For this enum, the error message is determined based on the specific error case that was encountered.

     - SeeAlso: `noRecipientDIDSetError`, `noValidServiceFoundError(did:)`, `noSenderDIDSetError`, `unknownAttachmentDataTypeError`, `messageAttachmentWithoutIDError`, `messageInvalidBodyDataError`, `didcommError(msg:)`
     */
    public var message: String {
        switch self {
        case .noRecipientDIDSetError:
            return "Message has no recipient set, to send a message please set the \"to\""
        case .noSenderDIDSetError:
            return "Message has no sender set, to send a message please set the \"from\""
        case let .noValidServiceFoundError(did):
            return "The did (\(did)) has no valid services"
        case .unknownAttachmentDataTypeError:
            return "Unknown AttachamentData type was found while decoding message"
        case .messageAttachmentWithoutIDError:
            return "While decoding a message, a message attachment was found without \"id\" this is invalid"
        case .messageInvalidBodyDataError:
            return "While decoding a message, a body was found to be invalid while decoding"
        case .didcommError(let msg):
            return "DIDComm error as ocurred with message: \(msg)"
        }
    }
}

extension MercuryError: Equatable {
    public static func == (lhs: MercuryError, rhs: MercuryError) -> Bool {
        lhs.message == rhs.message
    }
}

/**
 An enum representing a known error in a Pluto API response.

 - Note: When an error occurs during an API request/response cycle, the server may return an error object in the response. This object may include an error code and an error message. If the error received conforms to the `KnownPrismError` protocol, it will be classified as a known error.

 - SeeAlso: `UnknownPrismError`, `KnownPrismError`
 */
public enum PlutoError: KnownPrismError {

    /**
     An error case representing missing data persistence.

     - Parameters:
        - type: The type of data that is missing.
        - affecting: The action that is being taken when the error occurs.
     */
    case missingDataPersistence(type: String, affecting: String)

    /**
     An error case representing missing required fields.

     - Parameters:
        - type: The type of data that is missing required fields.
        - fields: An array of the required fields.
     */
    case missingRequiredFields(type: String, fields: [String])

    /**
     An error case representing a duplicate object.

     - Parameters:
        - type: The type of object that is a duplicate.
     */
    case duplication(type: String)

    /// An error case representing an unknown credential type.
    case unknownCredentialTypeError

    /// An error case representing invalid JSON in a credential.
    case invalidCredentialJsonError

    /// The error code returned by the server.
    public var code: Int {
        switch self {
        case .missingDataPersistence:
            return 41
        case .missingRequiredFields:
            return 42
        case .duplication:
            return 43
        case .unknownCredentialTypeError:
            return 44
        case .invalidCredentialJsonError:
            return 45
        }
    }

    /**
     The error message returned by the server.

     - Note: For this enum, the error message is determined based on the specific error case that was encountered.

     - SeeAlso: `missingDataPersistence(type:affecting:)`, `missingRequiredFields(type:fields:)`, `duplication(type:)`, `unknownCredentialTypeError`, `invalidCredentialJsonError`
     */
    public var message: String {
        switch self {
        case let .missingDataPersistence(type, affecting):
            return "\(type) is not persisted while trying to add or make changes to \(affecting)"
        case let .missingRequiredFields(type, fields):
            return "\(type) requires the following fields: \(fields.joined(separator: ", "))"
        case .duplication(let type):
            return "Trying to save \(type) with an ID that already exists"
        case .invalidCredentialJsonError:
            return "Could not decode the credential JSON"
        case .unknownCredentialTypeError:
            return "The credential type needs to be JWT or W3C"
        }
    }
}

extension PlutoError: Equatable {
    public static func == (lhs: PlutoError, rhs: PlutoError) -> Bool {
        lhs.message == rhs.message
    }
}

/**
 An enum representing a known error in a Pollux API response.

 - Note: When an error occurs during an API request/response cycle, the server may return an error object in the response. This object may include an error code and an error message. If the error received conforms to the `KnownPrismError` protocol, it will be classified as a known error.

 - SeeAlso: `UnknownPrismError`, `KnownPrismError`
 */
public enum PolluxError: KnownPrismError {

    /// An error case representing an invalid credential.
    case invalidCredentialError

    /// An error case representing an invalid JWT string.
    case invalidJWTString

    /// The error code returned by the server.
    public var code: Int {
        switch self {
        case .invalidCredentialError:
            return 51
        case .invalidJWTString:
            return 52
        }
    }

    /**
     The error message returned by the server.

     - Note: For this enum, the error message is determined based on the specific error case that was encountered.

     - SeeAlso: `invalidCredentialError`, `invalidJWTString`
     */
    public var message: String {
        switch self {
        case .invalidCredentialError:
            return "Invalid credential, could not decode"
        case .invalidJWTString:
            return "Invalid JWT while decoding credential"
        }
    }
}

extension PolluxError: Equatable {
    public static func == (lhs: PolluxError, rhs: PolluxError) -> Bool {
        lhs.message == rhs.message
    }
}

