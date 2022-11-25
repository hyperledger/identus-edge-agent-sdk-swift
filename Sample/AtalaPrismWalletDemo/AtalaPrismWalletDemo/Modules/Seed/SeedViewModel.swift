import Builders
import Domain
import Foundation

final class SeedViewModel: ObservableObject {

    private let apollo: Apollo
    @Published var createdSeed: Seed?
    @Published var randomMnemonics: [String]

    init() {
        self.apollo = ApolloBuilder().build()
        self.randomMnemonics = apollo.createRandomMnemonics()
    }

    func createSeed() {
        // Create a seed given mnemonics and optionally passphrase
        createdSeed = try? apollo.createSeed(mnemonics: randomMnemonics, passphrase: "")
    }

    func refreshMnemonics() {
        createdSeed = nil
        
        // Rendomises valid mnemonics
        randomMnemonics = apollo.createRandomMnemonics()
    }
}
