import Domain
import SwiftUI

protocol CreatePresentationViewModel: ObservableObject {
    var selectedCredentialType: CreatePresentationViewState.CredentialType { get set }
    var jwtClaims: [CreatePresentationViewState.JWTClaim] { get set }
    var anoncredsClaims: [CreatePresentationViewState.AnoncredsClaim] { get set }
    var selectedConnection: CreatePresentationViewState.Connection? { get set }
    var connections: [CreatePresentationViewState.Connection] { get set }

    func addJWTClaim()
    func addAnoncredsClaim()
    func addPath(to claimIndex: Int, path: String)
    func removePath(from claimIndex: Int, at pathIndex: Int)
    func createPresentation() async throws
}

struct CreatePresentationView<ViewModel: CreatePresentationViewModel>: View {
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            
            Form(content: {
                Section(header: Text("Select Connection")) {
                    Picker("Connection", selection: $viewModel.selectedConnection) {
                        ForEach(viewModel.connections) { connection in
                            Text(connection.recipientDID.string).tag(connection.id)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                Section(header: Text("Presentation Details")) {
                    Picker("Credential Type", selection: $viewModel.selectedCredentialType) {
                        ForEach(CreatePresentationViewState.CredentialType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }

                if viewModel.selectedCredentialType == .jwt {
                    Section(header: Text("JWT Claims")) {
                        ForEach(0..<viewModel.jwtClaims.count, id: \.self) { index in
                            JWTClaimView(
                                claim: $viewModel.jwtClaims[index],
                                claimIndex: index,
                                viewModel: viewModel
                            )
                        }
                        .onDelete { offsets in
                            viewModel.jwtClaims.remove(atOffsets: offsets)
                        }

                        Button("Add JWT Claim") {
                            viewModel.addJWTClaim()
                        }
                    }
                } else if viewModel.selectedCredentialType == .anoncreds {
                    Section(header: Text("Anoncreds Claims")) {
                        ForEach(0..<viewModel.anoncredsClaims.count, id: \.self) { index in
                            AnoncredsClaimView(claim: $viewModel.anoncredsClaims[index])
                        }
                        .onDelete { offsets in
                            viewModel.anoncredsClaims.remove(atOffsets: offsets)
                        }

                        Button("Add Anoncreds Claim") {
                            viewModel.addAnoncredsClaim()
                        }
                    }
                }
                Button("Create Presentation") {
                    Task {
                        try await viewModel.createPresentation()
                        dismiss()
                    }
                }
            })
            .navigationBarTitle("Create Presentation", displayMode: .inline)
        }
    }
}

struct JWTClaimView<ViewModel: CreatePresentationViewModel>: View {
    @Binding var claim: CreatePresentationViewState.JWTClaim
    var claimIndex: Int
    @ObservedObject var viewModel: ViewModel
    @State private var newPath: String = ""

    var body: some View {
        VStack {
            TextField("Name", text: $claim.name)
                .textInputAutocapitalization(.never)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)
            TextField("Type", text: $claim.type)
                .textInputAutocapitalization(.never)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)
            TextField("Format", text: $claim.format)
                .textInputAutocapitalization(.never)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)
            TextField("Pattern", text: $claim.pattern)
                .textInputAutocapitalization(.never)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)
            TextField("Constant", text: $claim.const)
                .textInputAutocapitalization(.never)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)
            Toggle(isOn: $claim.required) {
                Text("Required")
            }
            .padding(.vertical, 5)

            Section(header: Text("Paths")) {
                ForEach(claim.paths.indices, id: \.self) { index in
                    Text(claim.paths[index])
                        .padding()
                        .background(Color(.red).opacity(0.1))
                        .clipShape(Capsule())
                }
                .onDelete { offsets in
                    offsets.forEach { index in
                        viewModel.removePath(from: claimIndex, at: index)
                    }
                }

                HStack {
                    TextField("New Path", text: $newPath)
                    Button(action: {
                        guard !newPath.isEmpty else { return }
                        viewModel.addPath(to: claimIndex, path: newPath)
                        newPath = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
}

struct AnoncredsClaimView: View {
    @Binding var claim: CreatePresentationViewState.AnoncredsClaim

    var body: some View {
        TextField("Name", text: $claim.name)
        TextField("Predicate", text: $claim.predicate)
    }
}

private class MockViewModel: CreatePresentationViewModel {
    @Published var selectedConnection: CreatePresentationViewState.Connection? = nil
    @Published var connections: [CreatePresentationViewState.Connection] = [
        .init(hostDID: DID(method: "peer", methodId: "test1"), recipientDID: DID(method: "peer", methodId: "test2")),
        .init(hostDID: DID(method: "peer", methodId: "test3"), recipientDID: DID(method: "peer", methodId: "test4"))
    ]
    @Published var selectedCredentialType: CreatePresentationViewState.CredentialType = .jwt
    @Published var jwtClaims: [CreatePresentationViewState.JWTClaim] = []
    @Published var anoncredsClaims: [CreatePresentationViewState.AnoncredsClaim] = []

    func addJWTClaim() {
        jwtClaims.append(CreatePresentationViewState.JWTClaim())
    }

    func addAnoncredsClaim() {
        anoncredsClaims.append(CreatePresentationViewState.AnoncredsClaim())
    }

    func addPath(to claimIndex: Int, path: String) {
        if jwtClaims.indices.contains(claimIndex) {
            jwtClaims[claimIndex].paths.append(path)
        }
    }

    func removePath(from claimIndex: Int, at pathIndex: Int) {
        if jwtClaims.indices.contains(claimIndex),
           jwtClaims[claimIndex].paths.indices.contains(pathIndex) {
            jwtClaims[claimIndex].paths.remove(at: pathIndex)
        }
    }

    func createPresentation() async throws {
    }
}

struct CreatePresentationView_Previews: PreviewProvider {
    // Initialize your view model with some sample data
    fileprivate static let viewModel = {
        let viewModel = MockViewModel()

        viewModel.jwtClaims = [
            CreatePresentationViewState.JWTClaim(name: "Name", type: "Type", const: "Const", pattern: "Pattern", paths: ["$.vc.credentialSubject", "path2"], format: "Format", required: true),
            // Add more sample claims as needed
        ]
        viewModel.anoncredsClaims = [
            CreatePresentationViewState.AnoncredsClaim(name: "ClaimName", predicate: "Predicate")
            // Add more sample anoncreds claims as needed
        ]
        return viewModel
    }()
    static var previews: some View {
        // Return the view for previewing, injecting the view model with sample data
        CreatePresentationView(viewModel: viewModel)
            .previewLayout(.sizeThatFits) // Adjust the preview layout as needed
    }
}
