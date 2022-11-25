import Combine
import CoreData
import Domain

extension CDDIDPairDAO: DIDPairProvider {
    func getAll() -> AnyPublisher<[(holder: DID, other: DID, name: String?)], Error> {
        fetchController(context: readContext)
            .map { $0.map {
                (DID(from: $0.holderDID), DID(from: $0), $0.name)
            }}
            .eraseToAnyPublisher()
    }
    func getPair(otherDID: DID) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error> {
        fetchController(
            predicate: NSPredicate(format: "did == %@", otherDID.string),
            context: readContext
        )
        .map { $0.first.map {
            (DID(from: $0.holderDID), DID(from: $0), $0.name)
        }}
        .eraseToAnyPublisher()
    }
    func getPair(name: String) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error> {
        fetchController(
            predicate: NSPredicate(format: "name == %@", name),
            context: readContext
        )
        .map { $0.first.map {
            (DID(from: $0.holderDID), DID(from: $0), $0.name)
        }}
        .eraseToAnyPublisher()
    }
    func getPair(holderDID: DID) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error> {
        fetchController(
            predicate: NSPredicate(format: "holderDID.did == %@", holderDID.string),
            context: readContext
        )
        .map { $0.first.map {
            (DID(from: $0.holderDID), DID(from: $0), $0.name)
        }}
        .eraseToAnyPublisher()
    }
    func getPair(holderDID: DID, otherDID: DID) -> AnyPublisher<(holder: DID, other: DID, name: String?)?, Error> {
        fetchController(
            predicate: NSPredicate(format: "(holderDID.did == %@) AND (did == %@)", holderDID.string, otherDID.string),
            context: readContext
        )
        .map { $0.first.map {
            (DID(from: $0.holderDID), DID(from: $0), $0.name)
        }}
        .eraseToAnyPublisher()
    }
}
