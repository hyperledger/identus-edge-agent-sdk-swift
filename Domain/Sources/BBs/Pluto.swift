import Foundation
import Combine

public protocol Pluto {
    func storeDID(
        did: DID,
        keyPairIndex: Int,
        alias: String?
    ) -> AnyPublisher<Void, Error>

    func getAllDIDs() -> AnyPublisher<[(did: DID, keyPairIndex: Int, alias: String?)], Error>
    func getDIDInfo(did: DID) -> AnyPublisher<(did: DID, keyPairIndex: Int, alias: String?)?, Error>
    func getDIDInfo(alias: String) -> AnyPublisher<[(did: DID, keyPairIndex: Int)], Error>
    func getDIDKeyPairIndex(did: DID) -> AnyPublisher<Int?, Error>
}
