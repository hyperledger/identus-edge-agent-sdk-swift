import SwiftUI

protocol CredentialDetailViewModel: ObservableObject {
    var schema: String { get }
    var types: [String] { get }
    var issued: String { get }
    var error: Error? { get }
    var dismiss: Bool { get }
}

struct CredentialDetailNeoView<
    ViewModel: CredentialDetailViewModel
>: View {
    @StateObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 26) {
                VStack(alignment: .leading) {
                    HStack {
                        Image("ico_time")
                            .accentColor(.gray)
                        Text(viewModel.issued)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.dismiss, perform: { value in
            if value {
                self.presentationMode.wrappedValue.dismiss()
            }
        })
    }
}
