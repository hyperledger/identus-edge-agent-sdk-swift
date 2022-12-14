import Combine
import Foundation
import PrismAgent

final class QRCodeScannerViewModelImpl: QRCodeScannerViewModel {
    @Published var toasty: FancyToast?
    @Published var token: String?
    @Published var showInfo = false
    @Published var dismiss = false

    private let agent: PrismAgent

    init(token: String? = nil, showInfo: Bool = false, dismiss: Bool = false, agent: PrismAgent) {
        self.token = token
        self.showInfo = showInfo
        self.dismiss = dismiss
        self.agent = agent
    }

    func qrCodeFound(_ qrCode: String) {
        guard !showInfo, !dismiss else { return }
        token = qrCode
        self.showInfo = true
        Task {
            do {
                let parsedInvitation = try await agent.parseInvitation(str: qrCode)
            } catch {
                await MainActor.run { [weak self] in
                    self?.toasty = .init(
                        type: .error,
                        title: "Something went wrong accepting invitation",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    func cameraError(_ error: Error) {
        toasty = .init(
            type: .error,
            title: "Could not start agent",
            message: error.localizedDescription
        )
    }
}
