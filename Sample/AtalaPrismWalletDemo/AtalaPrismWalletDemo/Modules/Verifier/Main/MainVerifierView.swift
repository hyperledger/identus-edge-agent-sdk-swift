import SwiftUI

protocol MainVerifierViewRouter {
    associatedtype MediatorV: View
    associatedtype DidsV: View
    associatedtype ConnectionsV: View
    associatedtype MessagesV: View
    associatedtype PresentationV: View

    func routeToMediator() -> MediatorV
    func routeToDids() -> DidsV
    func routeToConnections() -> ConnectionsV
    func routeToMessages() -> MessagesV
    func routeToPresentations() -> PresentationV
}

struct MainVerifierView<Router: MainVerifierViewRouter>: View {
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

            router.routeToPresentations()
                .tabItem {
                    Text("Presentations")
                }
        }
    }
}
