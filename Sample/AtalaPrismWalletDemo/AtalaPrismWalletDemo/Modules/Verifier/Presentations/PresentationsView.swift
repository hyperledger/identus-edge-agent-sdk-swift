import SwiftUI

protocol PresentationsViewModel: ObservableObject {
    var presentations: [PresentationsViewState.Presentation] { get }
}

protocol PresentationsViewRouter {
    associatedtype PresentationDetailV: View
    associatedtype CreatePresentationV: View

    func routeToDetail(id: String) -> PresentationDetailV
    func routeToCreate() -> CreatePresentationV
}

struct PresentationsView<ViewModel: PresentationsViewModel, Router: PresentationsViewRouter>: View {
    @StateObject var viewModel: ViewModel
    @State var shouldRouteToCreate: Bool = false
    let router: Router

    var body: some View {
        NavigationStack {
            List(viewModel.presentations, id: \.name) { presentation in
                NavigationLink(destination: router.routeToDetail(id: presentation.id)) {
                    VStack(alignment: .leading) {
                        Text(presentation.name)
                            .font(.headline)
                        Text("To: \(presentation.to)")
                            .font(.subheadline)
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: {
                shouldRouteToCreate = true
            }) {
                Image(systemName: "plus")
            })
            .navigationBarTitle("Presentations", displayMode: .inline)
            .navigationDestination(isPresented: $shouldRouteToCreate) {
                router.routeToCreate()
            }
        }
    }
}
