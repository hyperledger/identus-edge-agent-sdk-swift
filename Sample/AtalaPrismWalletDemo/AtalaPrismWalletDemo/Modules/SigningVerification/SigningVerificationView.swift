//
//  SigningVerificationView.swift
//  AtalaPrismWalletDemo
//
//  Created by Goncalo Frade IOHK on 30/11/2022.
//

import SwiftUI

struct SigningVerificationView: View {
    @StateObject var model: SigningVerificationViewModel
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Button("Create DID") {
                    Task {
                        await self.model.createPrismDID()
                    }
                }
                .padding()
                .overlay(Capsule()
                    .stroke(
                        Color.black,
                        lineWidth: 2
                    ))
                if let str = model.createdDID?.string {
                    Text(str)
                    Text("Write a message:")
                        .bold()
                        .padding(.top)
                    TextField("Message", text: $model.message)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Button("Sign message") {
                        Task {
                            await self.model.signMessageWithDID()
                        }
                    }
                    .padding()
                    .overlay(Capsule()
                        .stroke(
                            Color.black,
                            lineWidth: 2
                        ))
                    if let str = model.signedMessage?.description {
                        Text(str)
                        Button("Verify message") {
                            Task {
                                await self.model.verifyMessage()
                            }
                        }
                        .padding()
                        .overlay(Capsule()
                            .stroke(
                                Color.black,
                                lineWidth: 2
                            ))
                        if let verification = model.verifiedMessage {
                            Text("Verification " + (verification ? "Success" : "Failed"))
                                .foregroundColor(verification ? .green : .red)
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct SigningVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        SigningVerificationView(model: SigningVerificationViewModel())
    }
}
