import Domain
import SwiftUI

protocol ContactsViewModel: ObservableObject {
    var createdPeerDID: String? { get }
    var createdPeerDIDAlias: String? { get }
    var contacts: [ContactsViewState.Contact] { get }

    func addContact(name: String, didString: String)
    func createNewPeerDIDForConnection(alias: String)
    func connectWithAgent(agentName: String, agentOOB: String)
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
    @State var showAddCerification = false
    @State var showDIDs = false

    var body: some View {
        List {
            ForEach(viewModel.contacts) { contact in
//                VStack(spacing: 8) {
//                    Text(contact.id)
//                    Text(contact.name)
//                }
                NavigationLink(contact.verified ? contact.name + " ✅" : contact.name + " ❌") {
                    router.routeToContact(pair: contact.pair)
                }
            }
        }
        #if !os(macOS)
        .navigationBarTitle("Contacts")
        .navigationBarItems(trailing: HStack {
            Button(action: {
                showAddCerification = true
            }) {
                Image(systemName: "person.crop.square.filled.and.at.rectangle")
            }
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
        #endif
        .sheet(isPresented: $showAddContact) {
            AddContactView<ViewModel>().environmentObject(viewModel)
        }
        .sheet(isPresented: $showAddCerification) {
            AddCertificationView<ViewModel>().environmentObject(viewModel)
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

struct AddCertificationView<ViewModel: ContactsViewModel>: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var newAgentName: String = "Prism"
    @State var newAgentOob: String = ""

    var body: some View {
        VStack {
            VStack {
                Text("Connect with agent")
                TextField("Name", text: $newAgentName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("OOB", text: $newAgentOob)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                HStack {
                    Button(action: {
                        viewModel.connectWithAgent(agentName: newAgentName, agentOOB: newAgentOob)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Connect")
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
