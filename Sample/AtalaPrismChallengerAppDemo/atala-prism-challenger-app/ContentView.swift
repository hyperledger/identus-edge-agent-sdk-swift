import SwiftUI

protocol ContentViewModel: ObservableObject {
    var did: String { get set }
    var isLoggedIn: Bool { get set }
    func login(name: String) async
    func verifyChallenge(url: URL) async
}

protocol ContentRouter {
    associatedtype LoggedInV: View
    
    func routeToLoggedInView() -> LoggedInV
}

struct ContentView<ViewModel: ContentViewModel, Router: ContentRouter>: View {
    
    enum Website: Int {
        case google
        case facebook
        
        var string: String {
            switch self {
            case .google:
                return "Google"
            case .facebook:
                return "Facebook"
            }
        }
        
        var image: String {
            switch self {
            case .google:
                return "GoogleLogo"
            case .facebook:
                return "FacebookLogo"

            }
        }
        
        var color: Color {
            switch self {
            case .google:
                return Color.red
            case .facebook:
                return Color(uiColor: UIColor(red: 66 / 255, green: 103 / 255, blue: 178 / 255, alpha: 1))
            }
        }
    }
    
    @StateObject var viewModel: ViewModel
    let router: Router
    let website = Website(rawValue: Int.random(in: 0...1))!
    
    var body: some View {
        NavigationView {
            VStack {
                Image(website.image)
                    .resizable()
                    .scaledToFit()
                Text("Please insert DID to Login:")
                TextField("DID", text: $viewModel.did)
                    .textFieldStyle(.roundedBorder)
                Button("Login with DID") {
                    Task {
                        await viewModel.login(name: website.string)
                    }
                }
                .padding(20)
                .background(website.color)
                .tint(.white)
                .clipShape(Capsule(style: .continuous))
                EmptyNavigationLink(
                    isActive: $viewModel.isLoggedIn,
                    destination: { router.routeToLoggedInView() }
                )
            }
            .padding()
        }
        .onOpenURL {url in
            Task {
                await viewModel.verifyChallenge(url: url)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    class ViewModel: ContentViewModel {
        var isLoggedIn: Bool = false
        var did: String = ""
        
        func login(name: String) {}
        func verifyChallenge(url: URL) {}
    }
    
    struct Router: ContentRouter {
        
        func routeToLoggedInView() -> some View {
            Text("Empty")
        }
    }
    
    static var previews: some View {
        ContentView(viewModel: ViewModel(), router: Router())
    }
}
