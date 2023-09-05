//
// IssueCredentialRecordPage.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

public struct IssueCredentialRecordPage: Codable {
    /// A string field containing the URL of the current API endpoint
    public var _self: String
    /// A string field containing the URL of the current API endpoint
    public var kind: String
    /// A string field indicating the type of resource that the contents field contains
    public var pageOf: String
    /// An optional string field containing the URL of the next page of results. If the API response does not contain any more pages, this field should be set to None.
    public var next: String?
    /// An optional string field containing the URL of the previous page of results. If the API response is the first page of results, this field should be set to None.
    public var previous: String?
    /// A sequence of IssueCredentialRecord objects representing the list of credential records that the API response contains
    public var contents: [IssueCredentialRecord]?

    public init(_self: String, kind: String, pageOf: String, next: String? = nil, previous: String? = nil, contents: [IssueCredentialRecord]? = nil) {
        self._self = _self
        self.kind = kind
        self.pageOf = pageOf
        self.next = next
        self.previous = previous
        self.contents = contents
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case _self = "self"
        case kind
        case pageOf
        case next
        case previous
        case contents
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _self = try container.decode(String.self, forKey: ._self)
        kind = try container.decode(String.self, forKey: .kind)
        pageOf = try container.decode(String.self, forKey: .pageOf)
        next = try container.decodeIfPresent(String.self, forKey: .next)
        previous = try container.decodeIfPresent(String.self, forKey: .previous)
        contents = try container.decodeIfPresent([IssueCredentialRecord].self, forKey: .contents)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_self, forKey: ._self)
        try container.encode(kind, forKey: .kind)
        try container.encode(pageOf, forKey: .pageOf)
        try container.encodeIfPresent(next, forKey: .next)
        try container.encodeIfPresent(previous, forKey: .previous)
        try container.encodeIfPresent(contents, forKey: .contents)
    }
}
