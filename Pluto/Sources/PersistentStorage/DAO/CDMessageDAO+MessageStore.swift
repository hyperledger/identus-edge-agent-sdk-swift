import Combine
import CoreData
import Domain

extension CDMessageDAO: MessageStore {
    func addMessages(messages: [Message]) -> AnyPublisher<Void, Error> {
        messages
            .publisher
            .flatMap { self.addMessage(msg: $0) }
            .eraseToAnyPublisher()
    }

    func addMessage(msg: Message) -> AnyPublisher<Void, Error> {
        guard
            let fromDID = msg.from,
            let toDID = msg.to
        else {
            return Fail(error: PlutoError.messageMissingFromOrToDIDError).eraseToAnyPublisher()
        }
        return pairDAO
            .fetchController(
                predicate: NSPredicate(
                    format: "(holderDID.did == %@) OR (holderDID.did == %@) OR (did == %@) OR (did == %@)",
                    fromDID.string,
                    toDID.string,
                    fromDID.string,
                    toDID.string
                ),
                context: writeContext
            )
            .first()
            .map { $0.first }
            .flatMap { pair in
                self.updateOrCreate(
                    msg.id,
                    context: writeContext
                ) { cdobj, _ in
                    try cdobj.fromDomain(msg: msg, pair: pair)
                }
            }
            .map { _ in }
            .eraseToAnyPublisher()
    }

    func removeMessage(id: String) -> AnyPublisher<Void, Error> {
        deleteByIDsPublisher([id], context: writeContext)
    }

    func removeAll() -> AnyPublisher<Void, Error> {
        deleteAllPublisher(context: writeContext)
    }
}

private extension CDMessage {

    func fromDomain(msg: Message, pair: CDDIDPair?) throws {
        self.messageId = msg.id
        self.from = msg.from?.string
        self.to = msg.to?.string
        self.type = msg.piuri
        self.dataJson = try JSONEncoder().encode(msg)
        self.createdTime = msg.createdTime
        self.pair = pair
    }
}
