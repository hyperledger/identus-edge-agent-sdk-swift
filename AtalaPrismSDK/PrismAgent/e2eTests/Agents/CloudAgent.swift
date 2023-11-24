import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

class CloudAgent {

    private static var transport: URLSessionTransport? = nil
    
    static var client: Client = {
        transport = URLSessionTransport()
        let client = Client(
            serverURL: URL(string: "http://localhost:8090")!,
            configuration: .init(dateTranscoder: MyDateTranscoder()),
            transport: transport!,
            middlewares: [
                APITokenMiddleware(apikey: "test"),
                StepReporterMiddleware()
            ] // TODO: read from environment
        )
        
        return client
    }()


    static func getConnections() async throws -> Components.Schemas.ConnectionsPage {
        let response = try await client.getConnections(.init())
        
        switch(response) {
        case .ok(let okResponse):
            switch(okResponse.body) {
            case .json(let response):
                return response
            }
        default:
            throw Error.WrongResponse
        }
    }
    
    static func getConnection(_ connectionId: String) async throws -> Components.Schemas.Connection {
        let response = try await client.getConnection(path: .init(connectionId: connectionId))
        
        switch(response) {
        case .ok(let okResponse):
            switch(okResponse.body) {
            case .json(let response):
                return response
            }
        default:
            throw Error.WrongResponse
        }
    }
    
    static func createConnection() async throws -> Components.Schemas.Connection {
        let body = Components.Schemas.CreateConnectionRequest(label: "Alice")
        let response = try await client.createConnection(.init(body: .json(body)))
        
        switch(response) {
        case .created(let okResponse):
            switch(okResponse.body) {
            case .json(let body):
                return body
            }
        default:
            throw Error.WrongResponse
        }
    }
    
    enum Error: Swift.Error, Equatable {
        case WrongResponse
    }
    
    private init() {}
}

// https://github.com/apple/swift-openapi-generator/issues/84
struct MyDateTranscoder: DateTranscoder {
    private var dateFormatters: [DateFormatter] = []

    func encode(_ date: Date) throws -> String {
        return dateFormatters[0].string(from: date)
    }

    func decode(_ string: String) throws -> Date {
        for formatter in dateFormatters {
            if let result = formatter.date(from: string) {
                return result
            }
        }
        throw DecodingError.dataCorrupted(.init(
            codingPath: [],
            debugDescription: "Date string does not match any of the expected formats"))
    }
    
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"
        dateFormatters.append(dateFormatter)
    }
}

extension HTTPField.Name {
    static let apikey = Self("apikey")!
}

struct APITokenMiddleware: ClientMiddleware {
    let apikey: String
    
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields[.apikey] = apikey
        return try await next(request, body, baseURL)
    }
    
    init(apikey: String) {
        self.apikey = apikey
    }
}

struct StepReporterMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        print("        ", "Cloud agent", request.method.rawValue, "to", request.path!)
        return try await next(request, body, baseURL)
    }
}
