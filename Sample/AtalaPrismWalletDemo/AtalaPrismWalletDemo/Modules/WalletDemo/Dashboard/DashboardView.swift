import SwiftUI

protocol DashboardRouter {
    associatedtype QRCodeScannerV: View

    func tabViews(qrCodeBinding: Binding<Bool>) -> [UIViewController]
    func routeToQRCodeReader() -> QRCodeScannerV
}

struct DashboardView<ViewModel: DashboardViewModel, Router: DashboardRouter>: View {
    let router: Router
    @StateObject var viewModel: ViewModel
    @State var presentProofOfRequest = false
    @State var presentQRCodeScanner = false

    var body: some View {
        DashboardRepresentableView(
            router: router,
            viewModel: viewModel,
            presentQRCodeScanner: $presentQRCodeScanner
        )
//        .clearFullScreenCover(isPresented: $presentProofOfRequest, animated: true) {
//            if let proofOfRequest = self.viewModel.proofOfRequest {
//                self.router.routeToPresentProofOfRequest(request: proofOfRequest)
//            }
//        }
//        .onChange(of: viewModel.proofOfRequest) { newValue in
//            if newValue != nil {
//                self.presentProofOfRequest = true
//            }
//        }
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(
            isPresented: self.$presentQRCodeScanner,
            onDismiss: {},
            content: {
                self.router.routeToQRCodeReader()
            }
        )
        .navigationBarHidden(true)
        .toastView(toast: $viewModel.toasty)
        .onAppear {
            self.viewModel.start()
        }
    }
}

private struct DashboardRepresentableView<
    ViewModel: DashboardViewModel, Router: DashboardRouter
>: UIViewControllerRepresentable {
    final class Coordinator {
        let viewController: DashboardTabViewController<ViewModel>

        init(viewController: DashboardTabViewController<ViewModel>) {
            self.viewController = viewController
        }
    }

    let router: Router
    @StateObject var viewModel: ViewModel
    @Binding var presentQRCodeScanner: Bool

    func makeCoordinator() -> Coordinator {
        let viewController = DashboardTabViewController(
            viewModel: viewModel,
            presentQRCodeScanner: $presentQRCodeScanner
        )
        viewController.viewControllers = router.tabViews(qrCodeBinding: $presentQRCodeScanner)
        return Coordinator(viewController: viewController)
    }

    func makeUIViewController(context: Context) -> DashboardTabViewController<ViewModel> {
        context.coordinator.viewController
    }

    func updateUIViewController(_ uiViewController: DashboardTabViewController<ViewModel>, context: Context) {
        context.coordinator.viewController.selectedIndex = viewModel.selectedIndex
    }
}
