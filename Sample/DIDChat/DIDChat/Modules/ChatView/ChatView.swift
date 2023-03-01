//
//  ChatView.swift
//  DIDChat
//
//  Created by Goncalo Frade IOHK on 23/02/2023.
//

import SwiftUI

protocol ChatViewModel: ObservableObject {
    var name: String { get }
    var sendingText: String { get set }
    var messages: [ChatViewState.Message] { get set }
    func sendMessage(text: String)
}

struct ChatView<ViewModel: ChatViewModel>: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.messages) { message in
                    MessageView(text: message.text, isSent: message.sent)
                }
            }
            .padding()

            HStack {
                TextField("Type your message...", text: $viewModel.sendingText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    viewModel.sendMessage(text: viewModel.sendingText)
                }) {
                    Text("Send")
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.name)
    }
}

struct MessageView: View {
    let text: String
    let isSent: Bool

    var body: some View {
        HStack {
            if isSent {
                Spacer()
                Text(text)
                    .padding(8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(4)
            } else {
                Text(text)
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(4)
                Spacer()
            }
        }
    }
}

private class MockedModel: ChatViewModel {
    var name: String = ""
    var sendingText: String = ""
    var messages = [ChatViewState.Message]()

    func sendMessage(text: String) {}
}

struct ChatView_Previews: PreviewProvider {

    static var previews: some View {
        ChatView(viewModel: MockedModel())
    }
}
