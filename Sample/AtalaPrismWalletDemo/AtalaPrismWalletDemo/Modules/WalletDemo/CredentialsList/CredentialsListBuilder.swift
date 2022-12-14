import Foundation
import PrismAgent
import SwiftUI
import UIKit

struct CredentialsListComponent {
    let container: DIContainer
}

struct CredentialsListBuilder {
    func build(component: CredentialsListComponent) -> UIViewController {
        let viewModel = CredentialsListViewModelImpl(
            agent: component.container.resolve(type: PrismAgent.self)!
        )
        let router = CredentialsListRouterImpl(container: component.container)
        let view = CredentialsListView<
            CredentialsListViewModelImpl, CredentialsListRouterImpl
        >(router: router).environmentObject(viewModel)

        return UIHostingController(rootView: view)
    }
}
