import SwiftUI

struct ContentRouterImpl: ContentRouter {
    
    func routeToLoggedInView() -> some View {
        LoggedInView()
    }
}
