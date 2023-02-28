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
    @State var mediatorDID: String = "did:peer:2.Ez6LSms555YhFthn1WV8ciDBpZm86hK9tp83WojJUmxPGk1hZ.Vz6MkmdBjMyB4TS5UbbQw54szm8yvMMf1ftGV2sQVYAxaeWhE.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwczovL21lZGlhdG9yLnJvb3RzaWQuY2xvdWQiLCJhIjpbImRpZGNvbW0vdjIiXX0"
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
