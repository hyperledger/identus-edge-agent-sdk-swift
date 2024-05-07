import Foundation

struct AnoncredsPresentationRequest: Codable {
    var nonce: String
    var name: String
    var version: String
    var requestedAttributes: [String: RequestedAttribute]
    var requestedPredicates: [String: RequestedPredicate]

    struct RequestedAttribute: Codable {
        var name: String?
        var names: [String]?
        var restrictions: [[String: String]]
    }

    struct RequestedPredicate: Codable {
        var name: String
        var pType: String
        var pValue: Int
    }
}
