import SwiftUI

protocol CredentialDetailViewModel: ObservableObject {
    var credential: CredentialDetailViewState { get }
}

struct CredentialDetailView<ViewModel: CredentialDetailViewModel>: View {
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Issuer:")
                    .font(.title2)
                Text(viewModel.credential.issuer)
                    .lineLimit(nil)
            }
            
            if let id = viewModel.credential.credentialDefinitionId {
                HStack {
                    Text("Credential Definition ID:")
                        .font(.title2)
                    Text(id)
                        .lineLimit(nil)
                }
            }
            if let id = viewModel.credential.schemaId {
                HStack {
                    Text("Schema ID:")
                        .font(.title2)
                    Text(id)
                        .lineLimit(nil)
                }
            }
            Text("Claims")
                .font(.title2)
            VStack(spacing: 8) {
                ForEach(viewModel.credential.claims.sorted(by: >), id: \.key) { key, value in
                    Text("\(key) - \(value)")
                }
            }
            .padding(.leading)
            
            Spacer()
        }
        .padding()
    }
}

private class MockViewModel: CredentialDetailViewModel {
    var credential: CredentialDetailViewState = .init(
        issuer: "did:test:adasdasd",
        claims: [
            "test1": "test",
            "test2": "test"
        ],
        credentialDefinitionId: "testId1",
        schemaId: "testId2"
    )
}

#Preview {
    CredentialDetailView(viewModel: MockViewModel())
}
