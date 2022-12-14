import Foundation
import SwiftUI

struct CredentialsListRouterImpl: CredentialsListRouter {
    let container: DIContainer

    func routeToCredentialDetail(id: String) -> some View {
        LazyView {
            CredentialDetailBuilder().build(component: .init(
                credentialId: id,
                container: container
            ))
        }
    }

    func routeToInsertToken() -> some View {
        AddNewContactBuilder()
            .build(component: .init(
                container: container,
                token: nil
            ))
    }
}
