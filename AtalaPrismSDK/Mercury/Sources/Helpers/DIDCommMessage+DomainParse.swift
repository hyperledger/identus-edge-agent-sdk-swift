import Core
import DIDCommxSwift
import Domain
import Foundation

extension DIDCommxSwift.Message {
    init(domain: Domain.Message, mediaType: MediaType) throws {
        let jsonString = String(data: domain.body, encoding: .utf8) ?? "{}"
        self.init(
            id: domain.id,
            typ: mediaType.rawValue,
            type: domain.piuri,
            body: jsonString.isEmpty ? "{}" : jsonString,
            from: domain.from?.string,
            to: domain.to.map { [$0.string] },
            thid: domain.thid,
            pthid: domain.pthid,
            extraHeaders: domain.extraHeaders,
            createdTime: domain.createdTime.millisecondsSince1970,
            expiresTime: domain.expiresTimePlus.millisecondsSince1970,
            fromPrior: domain.fromPrior,
            attachments: try domain.attachments.map {
                try Attachment(domain: $0)
            }
        )
    }

    func toDomain(castor: Castor) throws -> Domain.Message {
        guard let data = self.body.data(using: .utf8) else {
            throw MercuryError.messageInvalidBodyDataError
        }
        let message = Domain.Message(
            id: self.id,
            piuri: self.type,
            from: try self.from.map { try DID(string: $0) },
            to: try self.to?.first.map { try DID(string: $0) },
            fromPrior: self.fromPrior,
            body: data,
            extraHeaders: self.extraHeaders,
            createdTime: self.createdTime
                .map { Date(milliseconds: $0) } ?? Date(),
            expiresTimePlus: self.expiresTime
                .map { Date(milliseconds: $0) } ?? Date(),
            attachments: try self.attachments?.map { try $0.toDomain() } ?? [],
            thid: self.thid,
            pthid: self.pthid,
            ack: []
        )
        return message
    }
}

extension DIDCommxSwift.Attachment {
    init(domain: Domain.AttachmentDescriptor) throws {
        self.init(
            data: try .init(domain: domain.data),
            id: domain.id,
            description: domain.description,
            filename: domain.filename?.joined(separator: "/"),
            mediaType: domain.mediaType,
            format: domain.format,
            lastmodTime: domain.lastmodTime.map { UInt64($0.timeIntervalSince1970) },
            byteCount: domain.byteCount.map { UInt64($0) }
        )
    }

    func toDomain() throws -> Domain.AttachmentDescriptor {
        guard let id = self.id else { throw MercuryError.messageAttachmentWithoutIDError }
        return .init(
            id: id,
            mediaType: self.mediaType,
            data: try self.data.toDomain(),
            filename: self.filename?.components(separatedBy: "/"),
            format: self.format,
            lastmodTime: self.lastmodTime.map { Date(timeIntervalSince1970: TimeInterval($0)) },
            byteCount: self.byteCount.map { Int($0) },
            description: self.description
        )
    }
}

extension DIDCommxSwift.AttachmentData {
    init(domain: Domain.AttachmentData) throws {
        if let base64Data = domain as? AttachmentBase64 {
            self = .base64(value: .init(base64: base64Data.base64, jws: nil))
        } else if let linkData = domain as? AttachmentLinkData {
            self = .links(value: .init(links: linkData.links, hash: linkData.hash, jws: nil))
        } else if let jsonData = domain as? AttachmentJsonData {
            self = .json(value: .init(json: String(data: jsonData.data, encoding: .utf8)!, jws: nil))
        } else if let jwsData = domain as? AttachmentJwsData {
            self = .base64(value: .init(base64: jwsData.base64, jws: jwsData.jws.signature))
        } else {
            throw MercuryError.unknownAttachmentDataTypeError
        }
    }

    func toDomain() throws -> Domain.AttachmentData {
        switch self {
        case let .base64(value):
            return AttachmentBase64(base64: value.base64)
        case let .links(value):
            return AttachmentLinkData(links: value.links, hash: value.hash)
        case let .json(value):
            guard let jsonData = value.json.data(using: .utf8) else {
                throw MercuryError.unknownAttachmentDataTypeError
            }
            return AttachmentJsonData(data: jsonData)
        }
    }
}
