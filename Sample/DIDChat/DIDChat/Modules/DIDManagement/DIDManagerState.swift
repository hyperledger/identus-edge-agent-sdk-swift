import Foundation

struct DIDManagerState {
    struct DIDInfo: Identifiable, Hashable {
        let didString: String
        let alias: String?

        var id: String { didString }
    }
}
