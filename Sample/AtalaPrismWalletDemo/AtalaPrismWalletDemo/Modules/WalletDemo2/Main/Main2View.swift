import SwiftUI

protocol Main2ViewRouter {
    associatedtype MediatorV: View
    associatedtype DidsV: View
    associatedtype ConnectionsV: View
    associatedtype MessagesV: View
    associatedtype CredentialsV: View

    func routeToMediator() -> MediatorV
    func routeToDids() -> DidsV
    func routeToConnections() -> ConnectionsV
    func routeToMessages() -> MessagesV
    func routeToCredentials() -> CredentialsV
}

struct Main2View<Router: Main2ViewRouter>: View {
    let router: Router

    var body: some View {
        TabView {
            router.routeToMediator()
                .tabItem {
                    Text("Mediator")
                }

            router.routeToDids()
                .tabItem {
                    Text("DID")
                }

            router.routeToConnections()
                .tabItem {
                    Text("Connections")
                }

            router.routeToMessages()
                .tabItem {
                    Text("Messages")
                }

            router.routeToCredentials()
                .tabItem {
                    Text("Credentials")
                }
        }
    }
}
