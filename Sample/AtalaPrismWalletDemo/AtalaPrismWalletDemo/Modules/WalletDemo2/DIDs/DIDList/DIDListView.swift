import SwiftUI

protocol DIDListViewModel: ObservableObject {
    var peerDIDs: [DIDListViewState.DID] { get }
    var prismDIDs: [DIDListViewState.DID] { get }
    var error: FancyToast? { get set }

    func addPrismDID()
    func addPeerDID()
}

struct DIDListView<ViewModel: DIDListViewModel>: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        List {
            Section(
                header: SectionHeader(title: "Peer DIDs", action: viewModel.addPeerDID)
            ) {
                ForEach(viewModel.peerDIDs, id: \.did) { peer in
                    DIDRow(did: peer.did, alias: peer.alias)
                }
            }

            Section(
                header: SectionHeader(title: "Prism DIDs", action: viewModel.addPrismDID)
            ) {
                ForEach(viewModel.prismDIDs, id: \.did) { prism in
                    DIDRow(did: prism.did, alias: prism.alias)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("DIDs")
        .toastView(toast: $viewModel.error)
    }
}

struct SectionHeader: View {
    let title: String
    let action: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
            Spacer()
            Button(action: action, label: {
                Image(systemName: "plus")
                    .foregroundColor(.accentColor)
            })
        }
        .padding(.horizontal)
    }
}

struct DIDRow: View {
    let did: String
    let alias: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(did)
                .font(.title3)
                .lineLimit(1)
                .truncationMode(.middle)
                .textSelection(.enabled)
            if let alias = alias {
                Text(alias)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
