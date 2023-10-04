import SwiftUI

protocol CredentialListViewModel: ObservableObject {
    var credentials: [CredentialListViewState.Credential] { get }
}

protocol CredentialListRouter {
    associatedtype CredentialDetailV: View

    func routeToCredentialDetail(id: String) -> CredentialDetailV
}

struct CredentialListView<
    ViewModel: CredentialListViewModel,
        Router: CredentialListRouter
>: View {
    @StateObject var viewModel: ViewModel
    let router: Router

    var body: some View {
        NavigationStack {
            List(viewModel.credentials, id: \.id) { credential in
                NavigationLink(value: credential) {
                    VStack(alignment: .leading) {
                        Text(credential.id)
                            .font(.headline)
                        Text(credential.issuer)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(credential.issuanceDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(credential.type)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationDestination(for: CredentialListViewState.Credential.self) {
                router.routeToCredentialDetail(id: $0.id)
            }
            .navigationTitle("My Credentials")
        }
    }
}
