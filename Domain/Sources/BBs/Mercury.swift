import Foundation

public enum UnpackOptions {
    case expectDecryptByAllKeys
    case unwrapReWrappingForward
}

public struct UnpackMetadata {
    public var encrypted: Bool
    public var authenticated: Bool
    public var nonRepudiation: Bool
    public var anonymousSender: Bool
    public var reWrappedInForward: Bool
    public var encryptedFromKid: String?
    public var encryptedToKids: [String]?
    public var signFrom: String?
    public var fromPriorIssuerKid: String?
    public var encAlgAuth: String?
    public var encAlgAnon: String?
    public var signAlg: String?
    public var signedMessage: String?
    public var fromPrior: String?

    public init(
        encrypted: Bool = false,
        authenticated: Bool = false,
        nonRepudiation: Bool = false,
        anonymousSender: Bool = false,
        reWrappedInForward: Bool = false,
        encryptedFromKid: String? = nil,
        encryptedToKids: [String]? = nil,
        signFrom: String? = nil,
        fromPriorIssuerKid: String? = nil,
        encAlgAuth: String? = nil,
        encAlgAnon: String? = nil,
        signAlg: String? = nil,
        signedMessage: String? = nil,
        fromPrior: String? = nil
    ) {
        self.encrypted = encrypted
        self.authenticated = authenticated
        self.nonRepudiation = nonRepudiation
        self.anonymousSender = anonymousSender
        self.reWrappedInForward = reWrappedInForward
        self.encryptedFromKid = encryptedFromKid
        self.encryptedToKids = encryptedToKids
        self.signFrom = signFrom
        self.fromPriorIssuerKid = fromPriorIssuerKid
        self.encAlgAuth = encAlgAuth
        self.encAlgAnon = encAlgAnon
        self.signAlg = signAlg
        self.signedMessage = signedMessage
        self.fromPrior = fromPrior
    }
}

public protocol Mercury {
    func packMessage(msg: Message) throws -> (result: String, signBy: String)
    func unpackMessage(msg: String, options: UnpackOptions) throws -> (result: Message, metadata: UnpackMetadata)
    @discardableResult
    func sendMessage(msg: Message) async throws -> Data?
}

extension Mercury {
    public func sendMessage(msg: Message) async throws -> Message? {
        try await sendMessage(msg: msg)
            .flatMap {
                try String(data: $0, encoding: .utf8).map {
                    try self.unpackMessage(msg: $0, options: .expectDecryptByAllKeys)
                }
            }?.result
    }
}
