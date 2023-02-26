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
        try await call(request: try makeRequest(
            url: url,
            method: .post,
            body: body,
            headers: headers,
            parameters: parameters
        ))
    }

    private func call(request: URLRequest) async throws -> Data? {
        let (data, response) = try await session.data(for: request)
        if let urlResponse = response as? HTTPURLResponse {
            guard 200...299 ~= urlResponse.statusCode else {
                throw CommonError.httpError(
                    code: urlResponse.statusCode,
                    message: String(data: data, encoding: .utf8) ?? ""
                )
            }
        }
        return data
    }

    private func makeRequest(
        url: URL,
        method: Method,
        body: Data?,
        headers: [String: String] = [:],
        parameters: [String: String]
    ) throws -> URLRequest {
        let urlParsed = URL(
            string: url
                .absoluteString
                .replacingOccurrences(
                    of: "http://host.docker.internal:8080",
                    with: "http://localhost:8080"
                )) ?? url
        var composition = URLComponents(url: urlParsed, resolvingAgainstBaseURL: true)
        if !parameters.isEmpty {
            composition?.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        }
        guard let url = composition?.url else {
            throw CommonError.invalidURLError(url: urlParsed.absoluteString)
        }
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        request.httpMethod = method.rawValue
        return request
    }
}
