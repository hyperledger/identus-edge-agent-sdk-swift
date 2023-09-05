//
// DIDResolutionMetadata.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

/// [DID resolution metadata](https://www.w3.org/TR/did-core/#did-resolution-metadata) 
public struct DIDResolutionMetadata: Codable {
    /// Resolution error constant according to [DID spec registries](https://www.w3.org/TR/did-spec-registries/#error)
    public var error: String?
    /// Resolution error message
    public var errorMessage: String?
    /// The media type of the returned DID document
    public var contentType: String?

    public init(error: String? = nil, errorMessage: String? = nil, contentType: String? = nil) {
        self.error = error
        self.errorMessage = errorMessage
        self.contentType = contentType
    }
}
