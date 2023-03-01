import Domain
import SwiftUI

protocol ContactsViewModel: ObservableObject {
    var createdPeerDID: String? { get }
    var createdPeerDIDAlias: String? { get }
    var contacts: [ContactsViewState.Contact] { get }

    func addContact(name: String, didString: String)
    func createNewPeerDIDForConnection(alias: String)
}

protocol ContactsListRouter {
    associatedtype ChatV: View
    associatedtype DIDsV: View

    func routeToContact(pair: DIDPair) -> ChatV
    func routeToDIDs() -> DIDsV
}

struct ContactList<ViewModel: ContactsViewModel, Router: ContactsListRouter>: View {
    @StateObject var viewModel: ViewModel
    @State var router: Router
    @State var showAddContact = false
    @State var showDIDs = false

    var body: some View {
        List {
            ForEach(viewModel.contacts) { contact in
//                VStack(spacing: 8) {
//                    Text(contact.id)
//                    Text(contact.name)
//                }
                NavigationLink(contact.name) {
                    router.routeToContact(pair: contact.pair)
                }
            }
        }
        .navigationBarTitle("Contacts")
        .navigationBarItems(trailing: HStack {
            Button(action: {
                showAddContact = true
            }) {
                Image(systemName: "plus")
            }
            Button(action: {
                showDIDs = true
            }) {
                Image(systemName: "doc.plaintext")
            }
        })
        .sheet(isPresented: $showAddContact) {
            AddContactView<ViewModel>().environmentObject(viewModel)
        }
        .sheet(isPresented: $showDIDs) {
            router.routeToDIDs()
        }
    }
}

struct AddContactView<ViewModel: ContactsViewModel>: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var newContactName: String = "Bob"
    @State var newContactPeerDID: String = "did:peer:2.Ez6LSc9cZDE5ioLyEV9WKtcpejzr7GvzcWHHP8rwnWeZwYyaV.Vz6MkkbB59SstKEkTLfLhGmc5iyesyMzCgmNuZqgMz3c4sLgy.SeyJyIjpbXSwicyI6ImRpZDpwZWVyOjIuRXo2TFNjUGI0ZG1GbUR3RXd2aGpLTXphN1p0TnhDRlVGeWkxb0xKSHF0REZDWWhTVC5WejZNa3J2TWFjV0daa3RiWk16UFdDQ2dCYUs1VEdYdGJSUlNWZk1rZmtROWlrTER0LlNleUpwWkNJNkltNWxkeTFwWkNJc0luUWlPaUprYlNJc0luTWlPaUpvZEhSd2N6b3ZMMjFsWkdsaGRHOXlMbkp2YjNSemFXUXVZMnh2ZFdRaUxDSmhJanBiSW1ScFpHTnZiVzB2ZGpJaVhYMCIsImEiOltdLCJ0IjoiZG0ifQ"
    @State var newPeerDIDAlias: String = ""

    var body: some View {
        VStack {
            VStack {
                Text("Connect with contact")
                TextField("Name", text: $newContactName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Peer DID", text: $newContactPeerDID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                HStack {
                    Button(action: {
                        viewModel.addContact(name: newContactName, didString: newContactPeerDID)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Create")
                    }
                    .padding()
                }
            }
            VStack {
                Text("Create peer DID for contact")
                TextField("Name", text: $newPeerDIDAlias)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if
                    let peerDID = viewModel.createdPeerDID,
                    let alias = viewModel.createdPeerDIDAlias
                {
                    VStack(spacing: 16) {
                        Text(peerDID)
                            .textSelection(.enabled)
                        Text("For alias: " + alias)
                    }
                }

                HStack {
                    Button(action: {
                        viewModel.createNewPeerDIDForConnection(alias: newPeerDIDAlias)
                    }) {
                        Text("Create Peer DID")
                    }
                    .padding()
                }
            }
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }
            .padding()
        }
    }
}

//private class MockModel: ContactsViewModel {
//    var contacts = [ContactsViewState.Contact]()
//
//    func addContact(name: String, didString: String) {}
//}

//struct ContactsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContactList(viewModel: MockModel(), router: <#_#>)
//    }
//}
