//
// RequestPresentationAction.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

public struct RequestPresentationAction: Codable {
    public enum Action: String, Codable, CaseIterable {
        case requestAccept = "request-accept"
        case requestReject = "request-reject"
        case presentationAccept = "presentation-accept"
        case presentationReject = "presentation-reject"
    }
    /// The action to perform on the proof presentation record.
    public var action: Action
    /// The unique identifier of the issue credential record - and hence VC - to use as the prover accepts the presentation request. Only applicable on the prover side when the action is `request-accept`.
    public var proofId: [String]?

    public init(action: Action, proofId: [String]? = nil) {
        self.action = action
        self.proofId = proofId
    }
}
