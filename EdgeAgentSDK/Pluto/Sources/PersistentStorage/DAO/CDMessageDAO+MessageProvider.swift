import Combine
import CoreData
import Domain

extension CDMessageDAO: MessageProvider {
    func getAll() -> AnyPublisher<[Message], Error> {
        fetchController(context: readContext)
            .tryMap {
                try $0.map {
                    try $0.toDomain()
                }}
            .eraseToAnyPublisher()
    }

    func getAllFor(did: DID) -> AnyPublisher<[Message], Error> {
        fetchController(
            predicate: NSPredicate(format: "(pair.did == %@) OR (pair.holderDID.did == %@)", did.string, did.string),
            context: readContext
        )
        .tryMap { try $0.map { try $0.toDomain() } }
        .eraseToAnyPublisher()
    }

    func getAllSent() -> AnyPublisher<[Message], Error> {
        fetchController(
            predicate: NSPredicate(format: "(direction == %d)", 0),
            context: readContext
        )
        .tryMap { try $0.map { try $0.toDomain() } }
        .eraseToAnyPublisher()
    }

    func getAllReceived() -> AnyPublisher<[Message], Error> {
        fetchController(
            predicate: NSPredicate(format: "(direction == %d)", 1),
            context: readContext
        )
        .tryMap { try $0.map { try $0.toDomain() } }
        .eraseToAnyPublisher()
    }

    func getAllSentTo(did: DID) -> AnyPublisher<[Message], Error> {
        fetchController(
            predicate: NSPredicate(format: "to == %@", did.string),
            context: readContext
        )
        .tryMap { try $0.map { try $0.toDomain() } }
        .eraseToAnyPublisher()
    }

    func getAllReceivedFrom(did: DID) -> AnyPublisher<[Message], Error> {
        fetchController(
            predicate: NSPredicate(format: "from == %@", did.string),
            context: readContext
        )
        .tryMap { try $0.map { try $0.toDomain() } }
        .eraseToAnyPublisher()
    }

    func getAllOfType(type: String, relatedWithDID: DID?) -> AnyPublisher<[Message], Error> {
        fetchController(
            predicate: NSPredicate(format: "type == %@", type),
            context: readContext
        )
        .tryMap { try $0.map { try $0.toDomain() } }
        .eraseToAnyPublisher()
    }

    func getAll(from: DID, to: DID) -> AnyPublisher<[Message], Error> {
        fetchController(
            predicate: NSPredicate(format: "(from == %@) OR (to == %@)", from.string, to.string),
            context: readContext
        )
        .tryMap { try $0.map { try $0.toDomain() } }
        .eraseToAnyPublisher()
    }

    func getMessage(id: String) -> AnyPublisher<Message?, Error> {
        fetchByIDsPublisher(id, context: readContext)
            .tryMap { try $0?.toDomain() }
            .eraseToAnyPublisher()
    }
}

private extension CDMessage {
    func toDomain() throws -> Message {
        try JSONDecoder().decode(CodableMessage.self, from: dataJson).message
    }
}
