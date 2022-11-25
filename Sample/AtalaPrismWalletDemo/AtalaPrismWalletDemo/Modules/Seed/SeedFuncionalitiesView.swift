import SwiftUI

struct SeedFuncionalitiesView: View {
    @StateObject var model: SeedViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("Mnemonics:")
                .bold()
            Text(model.randomMnemonics.joined(separator: ", "))
            if
                let seed = model.createdSeed
            {
                Text("Seed created from mnemonics")
                    .bold()
                Text(seed.value.base64EncodedString())
            }
            HStack(alignment: .center, spacing: 16) {
                Button("Refresh mnemonics") {
                    self.model.refreshMnemonics()
                }
                .padding()
                .overlay(Capsule()
                    .stroke(
                        Color.black,
                        lineWidth: 2
                    ))
                Spacer()
                Button("Create Seed") {
                    self.model.createSeed()
                }
                .padding()
                .overlay(Capsule()
                    .stroke(Color.black, lineWidth: 2))
            }
            Spacer()
        }
        .padding()
    }
}

struct SeedView_Previews: PreviewProvider {
    static var previews: some View {
        SeedFuncionalitiesView(model: SeedViewModel())
    }
}
