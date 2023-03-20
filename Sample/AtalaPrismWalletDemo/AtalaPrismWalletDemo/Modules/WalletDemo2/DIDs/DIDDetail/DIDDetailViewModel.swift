import Combine
import Domain
import Foundation
import PrismAgent

final class DIDDetailViewModelImpl: DIDDetailViewModel {
    @Published var state: DIDDetailViewState = .init(
        did: "",
        alias: nil,
        publicKeys: [],
        services: [:]
    )
    private let pluto: Pluto
    private let did: String

    init(did: String, pluto: Pluto) {
        self.did = did
        self.pluto = pluto
    }

//    func bind() {
//        let did = try! DID(string: did)
//        switch did.method {
//        case "prism":
//            pluto
//                .getPeerDIDInfo(did: <#T##DID#>)
//        }
//    }
}
