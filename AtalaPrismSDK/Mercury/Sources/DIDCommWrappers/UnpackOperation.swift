import Combine
import Core
import DIDCommSwift
import Domain
import Foundation

final class UnpackOperation {
    private let didcomm: DIDComm
    private let castor: Castor
    private let logger: PrismLogger
    private var published = CurrentValueSubject<Domain.Message?, Error>(nil)
    private var cancellable: AnyCancellable?

    init(didcomm: DIDComm, castor: Castor, logger: PrismLogger) {
        self.didcomm = didcomm
        self.castor = castor
        self.logger = logger
    }

    func unpackEncrypted(messageString: String) async throws -> Domain.Message {
        return try await didcomm.unpack(params: .init(
            packedMessage: messageString
        )).message.toDomain(castor: castor)
    }
}
