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
                        Text(credential.credentialType)
                            .font(.headline)
                        Text(credential.issuer)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(credential.issuanceDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if !credential.type.isEmpty {
                            Spacer()
                            HStack {
                                ForEach(credential.type, id: \.self) { type in
                                    Text(type)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                        }
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
