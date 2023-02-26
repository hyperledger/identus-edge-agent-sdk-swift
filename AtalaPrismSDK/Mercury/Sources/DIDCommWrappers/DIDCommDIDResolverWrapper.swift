import Combine
import Core
import DIDCommxSwift
import Domain
import Foundation

class DIDCommDIDResolverWrapper {
    let logger: PrismLogger
    let castor: Castor
    var publisher = PassthroughSubject<DIDDocument, Error>()
    var cancellables = [AnyCancellable]()

    init(castor: Castor, logger: PrismLogger) {
        self.castor = castor
        self.logger = logger
    }

    fileprivate func resolve(did: String) {
        Task { [weak self] in
            let document = try await castor.resolveDID(did: DID(string: did))
            self?.publisher.send(document)
        }
    }
}

extension DIDCommDIDResolverWrapper: DidResolver {
    func resolve(did: String, cb: OnDidResolverResult) -> ErrorCode {
        publisher
            .first()
            .sink { [weak self] in
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    self?.logger.error(message: "Error trying to resolve DID", metadata: [
                        .publicMetadata(key: "Error", value: error.localizedDescription)
                    ])
                    try? cb.error(
                        err: ErrorKind.DidNotResolved(message: error.localizedDescription),
                        msg: error.localizedDescription
                    )
                }
            } receiveValue: { [weak self] in
                do {
                    self?.logger.debug(message: "Success resolving DID", metadata: [
                        .maskedMetadataByLevel(key: "DID", value: did, level: .debug)
                    ])
                    try cb.success(result: try DidDoc(from: $0))
                } catch {
                    self?.logger.error(message: "Error trying to resolve DID", metadata: [
                        .publicMetadata(key: "Error", value: error.localizedDescription)
                    ])
                    try? cb.error(
                        err: ErrorKind.DidNotResolved(message: error.localizedDescription),
                        msg: error.localizedDescription
                    )
                }
            }
            .store(in: &cancellables)
        resolve(did: did)
        return .success
    }
}

extension DidDoc {
    init(from: DIDDocument) throws {
        let did = from.id.string
        var authentications = [String]()
        var keyAgreements = [String]()
        let verificationMethods: [VerificationMethod] = try from.verificationMethods.compactMap {
            guard
                let jsonKeys = try $0.publicKeyJwk?.convertToJsonString(),
                let crv = $0.publicKeyJwk?["crv"]
            else { return nil }
            switch crv {
            case "X25519":
                keyAgreements.append($0.id.string)
            case "Ed25519":
                authentications.append($0.id.string)
            default:
                break
            }
            return VerificationMethod(
                id: $0.id.string,
                type: .jsonWebKey2020,
                controller: $0.controller.string,
                verificationMaterial: .jwk(value: jsonKeys)
            )
        }

        let services = from.services.compactMap { service in
            if service.type.contains("DIDCommMessaging") {
                return service.serviceEndpoint.first.map {
                    Service(
                        id: service.id,
                        kind: .didCommMessaging(
                            value: .init(
                                serviceEndpoint: $0.uri,
                                accept: $0.accept,
                                routingKeys: $0.routingKeys
                            )
                        )
                    )
                }
            } else {
                return service.serviceEndpoint.first.map {
                    Service(
                        id: service.id,
                        kind: .other(value: $0.uri)
                    )
                }
            }
        }
        self.init(
            did: did,
            keyAgreements: keyAgreements,
            authentications: authentications,
            verificationMethods: verificationMethods,
            services: services
        )
    }
}

extension Dictionary where Key == String, Value == String {
    func convertToJsonString() throws -> String? {
        try Core.convertToJsonString(dic: self)
    }
}
