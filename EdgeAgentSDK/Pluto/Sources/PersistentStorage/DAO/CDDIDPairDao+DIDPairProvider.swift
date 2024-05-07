import Combine
import CoreData
import Domain

extension CDDIDPairDAO: DIDPairProvider {
    func getAll() -> AnyPublisher<[DIDPair], Error> {
        fetchController(context: readContext)
            .map { $0.map {
                $0.toDomain()
            }}
            .eraseToAnyPublisher()
    }
    func getPair(otherDID: DID) -> AnyPublisher<DIDPair?, Error> {
        fetchController(
            predicate: NSPredicate(format: "did == %@", otherDID.string),
            context: readContext
        )
        .map { $0.first.map {
            $0.toDomain()
        }}
        .eraseToAnyPublisher()
    }
    func getPair(name: String) -> AnyPublisher<DIDPair?, Error> {
        fetchController(
            predicate: NSPredicate(format: "name == %@", name),
            context: readContext
        )
        .map { $0.first.map {
            $0.toDomain()
        }}
        .eraseToAnyPublisher()
    }
    func getPair(holderDID: DID) -> AnyPublisher<DIDPair?, Error> {
        fetchController(
            predicate: NSPredicate(format: "holderDID.did == %@", holderDID.string),
            context: readContext
        )
        .map { $0.first.map {
            $0.toDomain()
        }}
        .eraseToAnyPublisher()
    }
    func getPair(holderDID: DID, otherDID: DID) -> AnyPublisher<DIDPair?, Error> {
        fetchController(
            predicate: NSPredicate(format: "(holderDID.did == %@) AND (did == %@)", holderDID.string, otherDID.string),
            context: readContext
        )
        .map { $0.first.map {
            $0.toDomain()
        }}
        .eraseToAnyPublisher()
    }
}

extension CDDIDPair {
    func toDomain() -> DIDPair {
        return DIDPair(
            holder: DID(
                schema: self.holderDID.schema,
                method: self.holderDID.method,
                methodId: self.holderDID.methodId
            ),
            other: DID(
                schema: self.schema,
                method: self.method,
                methodId: self.methodId
            ),
            name: self.name
        )
    }
}
