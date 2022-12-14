import Combine
import Foundation
import SwiftUI
import UIKit
import PrismAgent

struct DashboardRouterImpl: DashboardRouter {
    let container: DIContainer
    let agent: PrismAgent

    func tabViews(qrCodeBinding: Binding<Bool>) -> [UIViewController] {
        [
            makeCredentialsVC(),
            makeContactsVC(qrCodeBinding: qrCodeBinding),
            makeHomeVC(),
            makeServicesVC(),
            makeSettingsVC()
        ]
    }

//    func routeToPresentProofOfRequest(request: ProofOfRequestDomain) -> some View {
//        ShareContactBuilder().build(component: .init(
//            container: container,
//            proofOfRequest: request,
//            proofOfRequestRepository: IntegrationStore.shared.proofOfRequestRepository,
//            contactsRepository: IntegrationStore.shared.contactsRepository,
//            credentialsRepository: IntegrationStore.shared.credentialsRepository
//        ))
//    }

    func routeToQRCodeReader() -> some View {
        QRCodeScannerBuilder().build(component: .init(container: container))
    }

    private func makeCredentialsVC() -> UIViewController {
        let viewController = CredentialsListBuilder().build(component: .init(container: container))

        viewController.tabBarItem = UITabBarItem(
            title: "tab_credentials".localize(),
            image: UIImage(named: "tab_credentials"),
            tag: 0
        )
        return viewController
    }

    private func makeContactsVC(qrCodeBinding: Binding<Bool>) -> UIViewController {
//        let viewController = ContactsListBuilder().buildVC(component: .init(
//            container: container,
//            contactsRepository: IntegrationStore.shared.contactsRepository,
//            appConfiguration: AppConfiguration(),
//            presentQRCode: qrCodeBinding
//        ))

        let viewController = UIViewController()
        
        viewController.tabBarItem = UITabBarItem(
            title: "tab_contacts".localize(),
            image: UIImage(named: "tab_contacts"),
            tag: 1
        )
        return viewController
    }

    private func makeHomeVC() -> UIViewController {
        let viewController = HomeBuilder().buildVC(component: .init(
            container: container
        ))

        viewController.tabBarItem = UITabBarItem(title: nil, image: nil, tag: 2)
        return viewController
    }

    private func makeServicesVC() -> UIViewController {
        let viewController = UIViewController()

        viewController.tabBarItem = UITabBarItem(
            title: "tab_services".localize(),
            image: UIImage(named: "tab_services"),
            tag: 3
        )
        return viewController
    }

    private func makeSettingsVC() -> UIViewController {
        let viewController = UIViewController()

        viewController.tabBarItem = UITabBarItem(
            title: "tab_settings".localize(),
            image: UIImage(named: "tab_settings"),
            tag: 4
        )
        return viewController
    }
}
