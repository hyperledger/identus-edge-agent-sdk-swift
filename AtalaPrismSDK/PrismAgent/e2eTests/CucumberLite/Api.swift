import Foundation

class Api {
    static func get(from url: URL) async throws -> [String : Any] {
        let session = URLSession.shared
        let (data, _) = try await session.data(from: url)
        return try (JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])!
    }
    
    static func get(from url: URL) async throws -> String {
        let session = URLSession.shared
        let (data, _) = try await session.data(from: url)
        return String(bytes: data, encoding: String.Encoding.utf8)!
    }
}

enum ApiError: Error {
    case failure(message: String)
}
