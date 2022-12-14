import SwiftUI

protocol CredentialsListViewModel: ObservableObject {
    var credentials: [CredentialsListState.Credential] { get }
    var showEmptyList: Bool { get }
}

protocol CredentialsListRouter {
    associatedtype CredentialDetail: View
    associatedtype AddContactV: View

    func routeToCredentialDetail(id: String) -> CredentialDetail
    func routeToInsertToken() -> AddContactV
}

struct CredentialsListView<
    ViewModel: CredentialsListViewModel,
    Router: CredentialsListRouter
>: View {
    let router: Router
    @State var presentAddNewContact = false
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider()
                VStack(spacing: 16) {
                    if viewModel.showEmptyList {
                        VStack(spacing: 16) {
                            Spacer()
                            Image("img_notifications_tray")
                            Text("credentials_empty_title".localize())
                                .font(.system(
                                    size: 20,
                                    weight: .semibold,
                                    design: .default
                                ))
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                            Text("credentials_empty_subtitle".localize())
                                .font(.system(
                                    size: 16,
                                    weight: .regular,
                                    design: .default
                                ))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(.gray))
                            Spacer()
                        }
                        .padding(.horizontal)
                    } else {
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVStack(alignment: .leading) {
                                ForEach(viewModel.credentials) { credential in
                                    NavigationLink(
                                        destination: router.routeToCredentialDetail(id: credential.id),
                                        label: {
                                            card(credential: credential)
                                        }
                                    )
                                }
                            }
                            .padding()
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .topLeading
                            )
                        }
                        .padding(.bottom)
                    }
                }
                .navigationBarItems(
                    leading: Text("credentials_nav_title".localize()),
                    trailing: navigationButtons
                )
                .configureNavigationBar {
                    $0.barTintColor = .white
                    $0.setBackgroundImage(UIImage(), for: .default)
                    $0.shadowImage = UIImage()
                    $0.isTranslucent = true
                    $0.backgroundColor = .white
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .clearFullScreenCover(
                isPresented: $presentAddNewContact
            ) {
                self.router.routeToInsertToken()
            }
        }
    }

    private var navigationButtons: some View {
        HStack {
            addTokenButton
        }
    }

    private var addTokenButton: some View {
        Button(
            action: {
                self.presentAddNewContact = true
            },
            label: {
                Text("connections_add_new".localize())
                    .font(.caption2)
                    .underline()
                    .foregroundColor(Color(.gray))
            }
        )
    }

    private func card(credential: CredentialsListState.Credential) -> some View {
        HStack(spacing: 16) {
            credential.icon.image()
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(credential.title)
                    .bold()
                    .foregroundColor(.black)
                Text(credential.subtitle)
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 1)
            }

            Spacer()
            Image(systemName: "chevron.forward")
                .foregroundColor(.gray)
        }
        .frame(minHeight: 68)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color(.gray), radius: 3)
        )
    }
}

private extension CredentialsListState.Credential.Icon {
    func image() -> Image {
        switch self {
//        case .id, .nationalId:
//            return Image("icon-credential-id")
//        case .universityDegree:
//            return Image("icon-credential-university")
//        case .proofOfEmployment:
//            return Image("icon-credential-employment")
//        case .insurance:
//            return Image("icon-credential-insurance")
//        case .passport:
//            return Image("icon_passport")
//        case .payId:
//            return Image("icon_pay_id")
        case let .name(name):
            return Image(name)
        case let .data(data):
            guard let uiImage = UIImage(data: data) else {
                return Image("ico_placeholder_credential")
            }
            return Image(uiImage: uiImage)
        }
    }
}
//
//struct CredentialsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CredentialsListView<MockViewModel, MockRouter>(router: MockRouter())
//            .environmentObject(MockViewModel())
//    }
//}
//
//private class MockViewModel: CredentialsListViewModel {
//    var showEmptyList = false
//    var searchString = ""
//    var credentials: [CredentialsListState.Credential] = [
//        .init(
//            id: "",
//            icon: .id,
//            title: "Credential",
//            subtitle: "Contact"
//        )
//    ]
//}
//
//private struct MockRouter: CredentialsListRouter {
//    func routeToCredentialDetail(id: String) -> some View {
//        Text("")
//    }
//}
