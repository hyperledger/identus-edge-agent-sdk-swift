import SwiftUI

protocol BackupViewModel: ObservableObject {
    var newJWE: String? { get }

    func createNewJWE() async throws
    func backupWith(_ jwe: String) async throws
}

struct BackupView<ViewModel: BackupViewModel>: View {
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    @State private var jwe: String = ""
    var body: some View {
        VStack(spacing: 25) {
            VStack(spacing: 10) {
                AtalaButton(
                    configuration: .primary,
                    action: {
                        Task {
                            try await self.viewModel.createNewJWE()
                        }
                    },
                    label: {
                        Text("Create Backup".localize())
                    }
                )
                if let jwe = viewModel.newJWE {
                    Text(jwe)
                        .font(.caption)
                        .textSelection(.enabled)
                }
            }
            Divider()
            VStack(spacing: 8) {
                TextField("Insert backup here", text: $jwe)
                AtalaButton(
                    configuration: .primary,
                    action: {
                        Task {
                            try await self.viewModel.backupWith(jwe)
                            await MainActor.run {
                                self.dismiss()
                            }
                        }
                    },
                    label: {
                        Text("Backup".localize())
                    }
                )
            }
        }
        .padding(15)
    }
}
