import SwiftUI

protocol DIDDetailViewModel: ObservableObject {
    var state: DIDDetailViewState { get }
}

struct DIDDetailView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct DIDDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DIDDetailView()
    }
}
