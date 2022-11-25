import Foundation

/// Represents a Core Property in a DID Document.
/// This allows for extensability of the properties.
/// /// As specified in [w3 standards](https://www.w3.org/TR/did-core/#data-model)
public protocol DIDDocumentCoreProperty {}

/// Represents a DIDDocument with ``DID`` and ``[DIDDocumentCoreProperty]``
/// As specified in [w3 standards](https://www.w3.org/TR/did-core/#data-model)
public struct DIDDocument {
    public struct VerificationMethod {
        public let id: DIDUrl
        public let controller: DID
        public let type: String
        public let publicKeyJwk: [String: String]?
        public let publicKeyMultibase: String?

        public init(
            id: DIDUrl,
            controller: DID,
            type: String,
            publicKeyJwk: [String: String]? = nil,
            publicKeyMultibase: String? = nil
        ) {
            self.id = id
            self.controller = controller
            self.type = type
            self.publicKeyJwk = publicKeyJwk
            self.publicKeyMultibase = publicKeyMultibase
        }

        public var publicKey: PublicKey? {
            publicKeyMultibase
                .flatMap { Data(base64Encoded: $0) }
                .map { PublicKey(curve: type, value: $0) }
        }
    }

    public struct Service: DIDDocumentCoreProperty {
        public struct ServiceEndpoint {
            public let uri: String
            public let accept: [String]
            public let routingKeys: [String]

            public init(
                uri: String,
                accept: [String] = [],
                routingKeys: [String] = []
            ) {
                self.uri = uri
                self.accept = accept
                self.routingKeys = routingKeys
            }
        }

        public let id: String
        public let type: [String]
        public let serviceEndpoint: ServiceEndpoint

        public init(
            id: String,
            type: [String],
            serviceEndpoint: ServiceEndpoint
        ) {
            self.id = id
            self.type = type
            self.serviceEndpoint = serviceEndpoint
        }
    }

    public struct AlsoKnownAs: DIDDocumentCoreProperty {
        public let values: [String]

        public init(values: [String]) {
            self.values = values
        }
    }

    public struct Controller: DIDDocumentCoreProperty {
        public let values: [DID]

        public init(values: [DID]) {
            self.values = values
        }
    }

    public struct VerificationMethods: DIDDocumentCoreProperty {
        public let values: [VerificationMethod]

        public init(values: [VerificationMethod]) {
            self.values = values
        }
    }

    public struct Services: DIDDocumentCoreProperty {
        public let values: [Service]

        public init(values: [Service]) {
            self.values = values
        }
    }

    public struct Authentication: DIDDocumentCoreProperty {
        public let urls: [String]
        public let verificationMethods: [VerificationMethod]

        public init(urls: [String], verificationMethods: [VerificationMethod]) {
            self.urls = urls
            self.verificationMethods = verificationMethods
        }
    }

    public struct AssertionMethod: DIDDocumentCoreProperty {
        public let urls: [String]
        public let verificationMethods: [VerificationMethod]

        public init(urls: [String], verificationMethods: [VerificationMethod]) {
            self.urls = urls
            self.verificationMethods = verificationMethods
        }
    }

    public struct KeyAgreement: DIDDocumentCoreProperty {
        public let urls: [String]
        public let verificationMethods: [VerificationMethod]

        public init(urls: [String], verificationMethods: [VerificationMethod]) {
            self.urls = urls
            self.verificationMethods = verificationMethods
        }
    }

    public struct CapabilityInvocation: DIDDocumentCoreProperty {
        public let urls: [String]
        public let verificationMethods: [VerificationMethod]

        public init(urls: [String], verificationMethods: [VerificationMethod]) {
            self.urls = urls
            self.verificationMethods = verificationMethods
        }
    }

    public struct CapabilityDelegation: DIDDocumentCoreProperty {
        public let urls: [String]
        public let verificationMethods: [VerificationMethod]

        public init(urls: [String], verificationMethods: [VerificationMethod]) {
            self.urls = urls
            self.verificationMethods = verificationMethods
        }
    }

    public let id: DID
    public let coreProperties: [DIDDocumentCoreProperty]

    public init(id: DID, coreProperties: [DIDDocumentCoreProperty]) {
        self.id = id
        self.coreProperties = coreProperties
    }

    public var authenticate: [VerificationMethod] {
        guard
            let property = coreProperties
            .first(where: { $0 as? Authentication != nil })
            .map({ $0 as? Authentication }),
            let authenticateProperty = property
        else { return [] }

        guard authenticateProperty.urls.isEmpty else {
            return authenticateProperty.urls.compactMap { uri in
                verificationMethods.first { $0.id.string == uri }
            } + authenticateProperty.verificationMethods
        }
        return authenticateProperty.verificationMethods
    }

    public var verificationMethods: [VerificationMethod] {
        guard
            let property = coreProperties
            .first(where: { $0 as? VerificationMethods != nil })
            .map({ $0 as? VerificationMethods }),
            let verificationMethodsProperty = property
        else { return [] }

        return verificationMethodsProperty.values
    }

    public var services: [Service] {
        guard
            let property = coreProperties
            .first(where: { $0 as? Services != nil })
            .map({ $0 as? Services }),
            let servicesProperty = property
        else { return [] }

        return servicesProperty.values
    }
}
