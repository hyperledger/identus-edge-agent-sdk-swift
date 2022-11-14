import Foundation

protocol Pluto {
    func storeSeed(seed: Seed) async throws -> Session
    func storeDID(
        session: Session,
        did: DID,
        keyPairIndex: Int,
        alias: String?
    ) async throws

    func getSession() async -> Session
    func getDID(alias: String) async -> DID
    func getDIDKeyPairIndex(did: DID) async -> Int
}
