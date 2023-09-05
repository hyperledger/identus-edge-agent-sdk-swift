//
// VerificationPolicyConstraint.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

public struct VerificationPolicyConstraint: Codable {
    public var schemaId: String
    public var trustedIssuers: [String]?

    public init(schemaId: String, trustedIssuers: [String]? = nil) {
        self.schemaId = schemaId
        self.trustedIssuers = trustedIssuers
    }
}
