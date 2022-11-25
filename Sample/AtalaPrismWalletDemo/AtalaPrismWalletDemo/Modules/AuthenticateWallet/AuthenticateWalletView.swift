import SwiftUI

protocol AuthenticateWalletViewModel: ObservableObject {
    var did: String { get }
    var challenge: Challenge? { get }
    var error: Error? { get }
    
    func createPrismDID()
    func createPeerDID()
    func didReceiveChallenge(url: URL)
    func acceptChallenge() async
    func refuseChallenge() async
    func reset()
}

struct Challenge {
    let challenger: String
    let challenge: String
    let challengeAccepted: Bool
}

struct AuthenticateWalletView<ViewModel: AuthenticateWalletViewModel>: View {
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Image("img_logo_horizontal")
                .resizable()
                .scaledToFit()
            HStack {
                if viewModel.did.isEmpty {
                    Text("Please create a DID")
                        .font(.title)
                } else {
                    Text("\(viewModel.did)")
                        .textSelection(.enabled)
                        .font(.system(.footnote, weight: .ultraLight))
                }
            }
            HStack {
                Button("Create Prism DID") {
                    viewModel.createPrismDID()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .tint(.white)
                .clipShape(Capsule(style: .continuous))
                
                Button("Create Peer DID") {
                    viewModel.createPeerDID()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .tint(.white)
                .clipShape(Capsule(style: .continuous))
            }
            Button("Reset") {
                viewModel.reset()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .tint(.white)
            .clipShape(Capsule(style: .continuous))
            if let challenge = viewModel.challenge {
                VStack {
                    VStack(alignment: .center, spacing: 10) {
                        Text("You received an authentication challenge from:")
                        Text("\(challenge.challenger)")
                            .font(.system(size: 22, weight: .thin))
                    }
                    HStack {
                        Button("Accept Challenge") {
                            Task {
                                await viewModel.acceptChallenge()
                            }

                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .tint(.white)
                        .clipShape(Capsule(style: .continuous))
                        Button("Refuse Challenge") {
                            Task {
                                await viewModel.refuseChallenge()
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .tint(.white)
                        .clipShape(Capsule(style: .continuous))
                    }
                }
            }
            Spacer()
        }
        .padding()
        .onOpenURL {
            viewModel.didReceiveChallenge(url: $0)
        }
    }
}

struct AuthenticateWalletView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticateWalletView(viewModel: ViewModel())
    }
}

private class ViewModel: AuthenticateWalletViewModel {
    var did: String = ""
    var challenge: Challenge? = .init(challenger: "challenger", challenge: "challenge", challengeAccepted: false)
    var error: Error?
    func createPrismDID() {
        did = "did:prism:1234"
    }
    
    func createPeerDID() {
        did = "did:peer:1234"
    }
    
    func didReceiveChallenge(url: URL) {}
    
    func acceptChallenge() async {
        guard
            let aux = challenge,
            !aux.challengeAccepted
        else { return }
        challenge = .init(
            challenger: aux.challenger,
            challenge: aux.challenge,
            challengeAccepted: true
        )
    }
    
    func refuseChallenge() async {
        challenge = nil
    }
    
    func reset() {}
}
