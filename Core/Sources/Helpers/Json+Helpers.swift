import Foundation

public func convertToDictionary(data: Data) throws -> [String: String]? {
    try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
}

public func convertToDictionary(string: String) throws -> [String: String]? {
    guard let data = string.data(using: .utf8) else { return nil }
    return try convertToDictionary(data: data)
}

public func convertToJson(dic: [String: String]) throws -> Data? {
    try JSONSerialization.data(withJSONObject: dic)
}

public func convertToJsonString(dic: [String: String]) throws -> String? {
    String(data: try JSONSerialization.data(
        withJSONObject: dic,
        options: [.sortedKeys, .withoutEscapingSlashes]
    ), encoding: .utf8)
}
