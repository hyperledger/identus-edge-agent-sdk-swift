import Domain
import Foundation

struct SessionManager {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    private let session: URLSession
    private let timeout: TimeInterval

    init(session: URLSession, timeout: TimeInterval) {
        self.session = session
        self.timeout = timeout
    }

    func post(
        url: URL,
        body: Data? = nil,
        headers: [String: String] = [:],
        parameters: [String: String] = [:]
    ) async throws -> Data? {
        try await call(request: try makeRequest(url: url, method: .post, body: body, parameters: parameters))
    }

    private func call(request: URLRequest) async throws -> Data? {
        try await session.data(for: request).0
    }

    private func makeRequest(
        url: URL,
        method: Method,
        body: Data?,
        headers: [String: String] = [:],
        parameters: [String: String]
    ) throws -> URLRequest {
        var composition = URLComponents(url: url, resolvingAgainstBaseURL: true)
        composition?.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        guard let url = composition?.url else { throw MercuryError.invalidURLError }
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        request.httpMethod = method.rawValue
        return request
    }
}