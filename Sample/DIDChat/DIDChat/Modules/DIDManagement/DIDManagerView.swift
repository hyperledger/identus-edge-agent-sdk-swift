import SwiftUI

protocol DIDManagerViewModel: ObservableObject {
    var dids: [DIDManagerState.DIDInfo] { get }
}

struct DIDManagerView<ViewModel: DIDManagerViewModel>: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        List(viewModel.dids) { did in
            VStack(spacing: 16) {
                if
                    let alias = did.alias,
                    !alias.isEmpty
                {
                    Text("Alias: \(alias)")
                }
                Text(did.didString)
            }
        }
    }
}
