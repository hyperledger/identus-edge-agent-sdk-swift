import Combine
import CoreData
import Domain

extension CDMessageDAO: MessageStore {
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
            .flatMap {
                guard let pair = $0 else {
                    return Fail<CoreDataObject.ID, Error>(
                        error: PlutoError.didPairIsNotPersistedError
                    )
                    .eraseToAnyPublisher()
                }
                return self.updateOrCreate(
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

    func fromDomain(msg: Message, pair: CDDIDPair) throws {
        self.messageId = msg.id
        self.from = msg.from?.string
        self.to = msg.to?.string
        self.type = msg.piuri
        self.dataJson = try JSONEncoder().encode(msg)
        self.createdTime = msg.createdTime
        self.pair = pair
    }
}
