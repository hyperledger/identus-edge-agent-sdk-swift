import Domain
import Foundation

struct ContactsViewState {
    struct Contact: Identifiable, Hashable {
        let id: String
        let name: String
        let pair: DIDPair

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(name)
        }
    }

    struct PossibleContact: Identifiable, Hashable {
        let id: String
        let name: String
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(name)
        }
    }
}
