import SwiftUI

protocol HomeViewModel: ObservableObject {
    var profile: HomeState.Profile { get }
    var lastActivities: [HomeState.ActivityLog] { get }
}

protocol HomeRouter {
//    associatedtype ProfileV: View
//
//    func routeToProfile() -> ProfileV
//    func routeToVerifyCredential()
}

struct HomeView<ViewModel: HomeViewModel, Router: HomeRouter>: View {
    @StateObject var viewModel: ViewModel
    let router: Router

    @State var presentProfile = false
    @State var presentNotifications = false
    @State var presentMoreInfo = false
    @State var presentShareApp = false

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    VStack {
                        ProfileHeaderView(
                            profile: viewModel.profile
                        )
                        Spacer()
                        VStack(spacing: 22) {
                            if viewModel.lastActivities.isEmpty {
                                Image("img_empty_activity")
                            } else {
                                ActivityListView(activities: viewModel.lastActivities)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView<MockViewModel, MockRouter>(
            viewModel: MockViewModel(),
            router: MockRouter()
        )
    }
}

private class MockViewModel: HomeViewModel {
    var profile: HomeState.Profile = .init(
        profileImage: Data(),
        fullName: "John Doe"
    )
    var lastActivities: [HomeState.ActivityLog] = [
        .init(
            activityType: .connected,
            infoText: "Info",
            name: "Name",
            dateFormatter: RelativeDateTimeFormatter(),
            date: Date()
        ),
        .init(
            activityType: .shared,
            infoText: "Info",
            name: "Name",
            dateFormatter: RelativeDateTimeFormatter(),
            date: Date()
        ),
        .init(
            activityType: .received,
            infoText: "Info",
            name: "Name",
            dateFormatter: RelativeDateTimeFormatter(),
            date: Date()
        )
    ]
}

private struct MockRouter: HomeRouter {
    func routeToProfile() -> some View {
        Text("View not ready")
    }

    func routeToActivitys() -> some View {
        Text("View not ready")
    }

    func routeToMoreInfo() -> some View {
        Text("View not ready")
    }

    func routeToShareApp() -> some View {
        Text("View not ready")
    }

    func routeToNotifications() -> some View {
        Text("View not ready")
    }

    func routeToVerifyCredential() {}

    func routeToPayID() {}

    func routeToPayIDDetail() {}
}
