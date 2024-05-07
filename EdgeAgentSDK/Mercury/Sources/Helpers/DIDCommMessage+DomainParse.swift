import Core
import DIDCommSwift
import Domain
import Foundation

extension DIDCommSwift.Message {
    init(domain: Domain.Message, mediaType: MediaType) throws {
        let from = domain.from?.string
        self.init(
            id: domain.id,
            body: try domain.body.isEmpty ? "{}".tryToData() : domain.body,
            type: domain.piuri,
            typ: .plainText,
            from: from,
            to: domain.to.map { [$0.string] },
            createdTime: domain.createdTime,
            expiresTime: domain.expiresTimePlus,
            fromPrior: domain.fromPrior.flatMap {
                try? JSONDecoder().decode(FromPrior.self, from: $0.tryToData())
            },
            fromPriorJwt: nil,
            attachments: try domain.attachments.map { try .init(domain: $0) },
            pleaseAck: nil,
            ack: domain.ack.first,
            thid: domain.thid,
            pthid: domain.pthid,
            customHeaders: domain.extraHeaders
        )
    }

    func toDomain(castor: Castor) throws -> Domain.Message {
        Domain.Message(
            id: self.id,
            piuri: self.type,
            from: try self.from.map { try Domain.DID(string: $0) },
            to: try self.to?.first.map { try Domain.DID(string: $0) },
            fromPrior: try self.fromPrior.map { try JSONEncoder.didComm().encode($0) }?.tryToString(),
            body: self.body ?? Data(),
            extraHeaders: self.customHeaders ?? [:],
            createdTime: self.createdTime ?? Date(),
            expiresTimePlus: self.expiresTime ?? Date(),
            attachments: try self.attachments?.map { try $0.toDomain() } ?? [],
            thid: self.thid,
            pthid: self.pthid,
            ack: self.ack.map { [$0] } ?? []
        )
    }
}

extension DIDCommSwift.Attachment {
    init(domain: Domain.AttachmentDescriptor) throws {
        self.init(
            id: domain.id,
            data: try domain.data.toDIDComm(),
            description: domain.description,
            filename: domain.filename?.first,
            mediaType: domain.mediaType,
            format: domain.format,
            lastModTime: domain.lastmodTime,
            byteCount: domain.byteCount
        )
    }

    func toDomain() throws -> Domain.AttachmentDescriptor {
        return .init(
            id: id,
            mediaType: self.mediaType,
            data: try self.data.toDomain(),
            filename: self.filename?.components(separatedBy: "/"),
            format: self.format,
            lastmodTime: self.lastModTime,
            byteCount: self.byteCount.map { Int($0) },
            description: self.description
        )
    }
}

extension Domain.AttachmentData {
    func toDIDComm() throws -> DIDCommSwift.AttachmentData {
        if let base64Data = self as? AttachmentBase64 {
            return Base64AttachmentData(
                hash: nil,
                jws: nil,
                base64: base64Data.base64
            )
        } else if let linkData = self as? AttachmentLinkData {
            return LinksAttachmentData(
                hash: linkData.hash,
                jws: nil,
                links: linkData.links
            )
        } else if let jsonData = self as? AttachmentJsonData {
            return try JsonAttachmentData(
                hash: nil,
                jws: nil,
                json: jsonData.data.tryToString()
            )
        } else if let jwsData = self as? AttachmentJwsData {
            return Base64AttachmentData(
                hash: nil,
                jws: jwsData.base64,
                base64: jwsData.jws.signature
            )
        } else {
            throw MercuryError.unknownAttachmentDataTypeError
        }
    }
}

extension DIDCommSwift.AttachmentData {
    func toDomain() throws -> Domain.AttachmentData {
        switch self {
        case let value as Base64AttachmentData:
            return AttachmentBase64(base64: value.base64)
        case let value as LinksAttachmentData:
            guard let hash = value.hash else {
                throw MercuryError.unknownAttachmentDataTypeError
            }
            return AttachmentLinkData(links: value.links, hash: hash)
        case let value as JsonAttachmentData:
            guard let jsonData = value.json.data(using: .utf8) else {
                throw MercuryError.unknownAttachmentDataTypeError
            }
            return AttachmentJsonData(data: jsonData)
        default:
            throw MercuryError.unknownAttachmentDataTypeError
        }
    }
}
