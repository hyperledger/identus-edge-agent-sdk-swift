//
//  MediatorView.swift
//  DIDChat
//
//  Created by Goncalo Frade IOHK on 23/02/2023.
//

import SwiftUI

protocol MediatorViewModel: ObservableObject {
    var routeToContactsList: Bool { get set }

    func viewHasAppeared()
    func initWithMediatorDID(mediatorDIDString: String)
}

protocol MediatorRouter {
    associatedtype ContactsListV: View

    func routeToContactsList() -> ContactsListV
}

struct MediatorView<ViewModel: MediatorViewModel, Router: MediatorRouter>: View {
    @StateObject var viewModel: ViewModel
    @State var mediatorDID: String = "did:peer:2.Ez6LSghwSE437wnDE1pt3X6hVDUQzSjsHzinpX3XFvMjRAm7y.Vz6Mkhh1e5CEYYq6JBUcTZ6Cp2ranCWRrv7Yax3Le4N59R6dd.SeyJ0IjoiZG0iLCJzIjp7InVyaSI6Imh0dHBzOi8vc2l0LXByaXNtLW1lZGlhdG9yLmF0YWxhcHJpc20uaW8iLCJhIjpbImRpZGNvbW0vdjIiXX19.SeyJ0IjoiZG0iLCJzIjp7InVyaSI6IndzczovL3NpdC1wcmlzbS1tZWRpYXRvci5hdGFsYXByaXNtLmlvL3dzIiwiYSI6WyJkaWRjb21tL3YyIl19fQ"
    @State var router: Router

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Mediator DID", text: $mediatorDID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button {
                    viewModel.initWithMediatorDID(mediatorDIDString: mediatorDID)
                } label: {
                    Text("Start mediation")
                }
            }
            .onAppear {
                viewModel.viewHasAppeared()
            }
            .navigationDestination(isPresented: $viewModel.routeToContactsList) {
                router.routeToContactsList()
            }
        }
    }
}

private class MockModel: MediatorViewModel {
    var routeToContactsList = false

    func viewHasAppeared() {
    }

    func initWithMediatorDID(mediatorDIDString: String) {
    }
}

private struct MockRouter: MediatorRouter {
    func routeToContactsList() -> some View {
        Text("")
    }
}

struct MediatorView_Previews: PreviewProvider {
    static var previews: some View {
        MediatorView(viewModel: MockModel(), router: MockRouter())
    }
}
