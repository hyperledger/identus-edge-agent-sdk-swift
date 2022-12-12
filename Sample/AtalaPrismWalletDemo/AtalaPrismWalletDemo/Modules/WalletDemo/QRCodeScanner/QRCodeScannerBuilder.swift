import SwiftUI
import PrismAgent

struct QRCodeScannerComponent: ComponentContainer {
    let container: DIContainer
}

struct QRCodeScannerBuilder: Builder {
    func build(component: QRCodeScannerComponent) -> some View {
        let viewModel = getViewModel(component: component) {
            QRCodeScannerViewModelImpl(agent: component.container.resolve(type: PrismAgent.self)!)
        }
        let router = QRCodeScannerRouterImpl(container: component.container)
        return QRCodeScannerView(router: router, viewModel: viewModel)
            .onDisappear {
                component.container.unregister(type: QRCodeScannerViewModelImpl.self)
            }
    }
}
