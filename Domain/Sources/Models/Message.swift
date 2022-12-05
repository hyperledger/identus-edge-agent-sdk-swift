import Foundation

public struct Message {
    public let id: String
    public let piuri: String
    public let from: DID?
    public let to: DID?
    public let fromPrior: String?
    public let body: Data
    public let extraHeaders: [String: String]
    public let createdTime: Date
    public let expiresTimePlus: Date
    public let attachments: [AttachmentDescriptor]
    public let thid: String?
    public let pthid: String?
    public let ack: [String]

    public init(
        id: String = UUID().uuidString,
        piuri: String,
        from: DID? = nil,
        to: DID? = nil,
        fromPrior: String? = nil,
        body: Data,
        extraHeaders: [String : String] = [:],
        createdTime: Date = Date(),
        expiresTimePlus: Date = Date(),
        attachments: [AttachmentDescriptor] = [],
        thid: String? = nil,
        pthid: String? = nil,
        ack: [String] = []
    ) {
        self.id = id
        self.piuri = piuri
        self.from = from
        self.to = to
        self.fromPrior = fromPrior
        self.body = body
        self.extraHeaders = extraHeaders
        self.createdTime = createdTime
        self.expiresTimePlus = expiresTimePlus
        self.attachments = attachments
        self.thid = thid
        self.pthid = pthid
        self.ack = ack
    }
}
