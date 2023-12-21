//
//  ChatView.swift
//  DIDChat
//
//  Created by Goncalo Frade IOHK on 23/02/2023.
//

import SwiftUI
import PhotosUI

protocol ChatViewModel: ObservableObject {
    var name: String { get }
    var selectedImage: Data? { get set }
    var sendingText: String { get set }
    var messages: [ChatViewState.Message] { get set }
    var error: FancyToast? { get set }
    func sendMessage(text: String)
    func accept(id: String)
}

struct ChatView<ViewModel: ChatViewModel>: View {
    @StateObject var viewModel: ViewModel
    @State var selectedImage: Image?
    @State var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.messages) { message in
                    MessageView(viewModel: viewModel, message: message)
                }
            }
            .padding()

            HStack(spacing: 16) {
                TextField("Type your message...", text: $viewModel.sendingText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                PhotosPicker(
                    selection: $pickerItem,
                    matching: .images
                ) {
                    VStack {
                        selectedImage?
                            .resizable()
                            .frame(width: 20, height: 20)
                        ?? Image(systemName: "photo")
                            .frame(width: 20, height: 20)
                    }
                }

                Button(action: {
                    viewModel.sendMessage(text: viewModel.sendingText)
                }) {
                    Text("Send")
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.name)
        .toastView(toast: $viewModel.error)
        .onChange(of: pickerItem, perform: { value in
            Task {
                self.viewModel.selectedImage = try await pickerItem?.loadTransferable(type: Data.self)
                selectedImage = try await pickerItem?.loadTransferable(type: Image.self)
            }
        })
        .onChange(of: viewModel.selectedImage, perform: {
            if $0 == nil {
                selectedImage = nil
                pickerItem = nil
            }
        })
    }
}

struct MessageView<ViewModel: ChatViewModel>: View {
    let title: String?
    let text: String
    let image: Data?
    let isSent: Bool
    let needResponse: Bool
    let id: String?
    let viewModel: ViewModel

    init(viewModel: ViewModel, message: ChatViewState.Message) {
        if let rec = message.agentReceived {
            self.id = rec.messageId
            self.needResponse = rec.needsResponse
            self.title = rec.title
        } else if let res = message.agentResponse {
            self.id = nil
            self.needResponse = false
            self.title = res.title
        } else {
            self.id = nil
            self.needResponse = false
            self.title = nil
        }
        self.text = message.text
        self.isSent = message.sent
        self.image = message.attachedImage
        self.viewModel = viewModel
    }

    var body: some View {
        HStack {
            if isSent {
                Spacer(minLength: 40)
                VStack(spacing: 8) {
                    if let title {
                        Text(title)
                            .bold()
                    }
                    Text(text)
                    if let image {
                        Image(uiImage: UIImage(data: image)!)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .padding(8)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(4)
            } else {
                VStack(spacing: 8) {
                    if let title {
                        Text(title)
                            .bold()
                    }
                    Text(text)
                    if let image {
                        Image(uiImage: UIImage(data: image)!)
                            .resizable()
                            .scaledToFit()
                    }
                    if needResponse, let id {
                        Button(action: {

                        }) {
                            Text("Accept")
                        }
                    }
                }
                .padding(8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(4)
                Spacer(minLength: 40)
            }
        }
    }
}

private class MockedModel: ChatViewModel {
    var name: String = ""
    var sendingText: String = ""
    var messages = [ChatViewState.Message]()
    var selectedImage: Data? = nil
    var photoPicker: PhotosPickerItem? = nil
    var error: FancyToast?

    func sendMessage(text: String) {}
    func accept(id: String) {}
}

struct ChatView_Previews: PreviewProvider {

    static var previews: some View {
        ChatView(viewModel: MockedModel())
    }
}
