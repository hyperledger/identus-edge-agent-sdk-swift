import OpenAPIRuntime
import Foundation
import OpenAPIURLSession

// Instantiate your chosen transport library.
let transport: ClientTransport = URLSessionTransport()

// Create a client to connect to a server URL documented in the OpenAPI document.
let client = Client(
    serverURL: URL(string: "http://localhost:8090")!,
    transport: transport
)

let response = try await client.getConnections(.init())

switch(response){
    
case .ok(_):
    print("ok")
case .badRequest(_):
    print("bad request")
case .internalServerError(_):
    print("internal error")
case .undocumented(statusCode: let statusCode, _):
    print("sei la")
}
