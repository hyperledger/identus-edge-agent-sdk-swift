import SwiftUI

struct DIDFuncionalitiesView: View {
    @StateObject var model: DIDFuncionalitiesViewModel
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
                    Button("Resolve DID") {
                        Task {
                            await self.model.resolveDID()
                        }
                    }
                    .padding()
                    .overlay(Capsule()
                        .stroke(
                            Color.black,
                            lineWidth: 2
                        ))
                    if let document = model.resolvedDID {
                        Text(document.description)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct DIDFuncionalitiesView_Previews: PreviewProvider {
    static var previews: some View {
        DIDFuncionalitiesView(model: .init())
    }
}
