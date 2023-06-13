import Foundation

/// Represents a Core Property in a DID Document.
/// This allows for extensability of the properties.
/// /// As specified in [w3 standards](https://www.w3.org/TR/did-core/#data-model)
public protocol DIDDocumentCoreProperty {}

/// Represents a DIDDocument with ``DID`` and ``[DIDDocumentCoreProperty]``
/// As specified in [w3 standards](https://www.w3.org/TR/did-core/#data-model)
/// A DID Document consists of a DID, public keys, authentication protocols, service endpoints, and other metadata. It is used to verify the authenticity and identity of the DID, and to discover and interact with the associated subjects or objects.
public struct DIDDocument {
    /// Represents a Verification Method, which is a public key or other evidence used to authenticate the identity of a Decentralized Identifier (DID) or other subject or object.
    ///
    /// A Verification Method consists of a type (indicating the type of key or evidence), a public key or other data, and optional metadata such as a controller (the DID that controls the verification method) and purpose (the intended use of the verification method). It is typically included in a DID Document or other authentication credential.
    public struct VerificationMethod {
        /// The ID of the verification method, represented as a DID URL.
        public let id: DIDUrl

        /// The controller of the verification method, represented as a DID.
        public let controller: DID

        /// The type of the verification method, indicated as a string (e.g. "EcdsaSecp256k1VerificationKey2019").
        public let type: String

        /// The public key of the verification method, represented as a JSON Web Key (JWK).
        public let publicKeyJwk: [String: String]?

        /// The public key of the verification method, represented as a multibase encoded string.
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
//
//        public var publicKey: PublicKey? {
//            publicKeyMultibase
//                .flatMap { Data(base64Encoded: $0) }
//                .map { PublicKey(curve: type, value: $0) }
//        }
    }

    /// Represents a Service, which is a capability or endpoint offered by a Decentralized Identifier (DID) or other subject or object.
    ///
    /// A Service consists of an ID, type, and service endpoint, as well as optional metadata such as a priority and a description. It is typically included in a DID Document and can be used to discover and interact with the associated DID or subject or object.
    public struct Service: DIDDocumentCoreProperty {
        /// Represents a service endpoint, which is a URI and other information that indicates how to access the service.
        public struct ServiceEndpoint {
            /// The URI of the service endpoint.
            public let uri: String

            /// The types of content that the service endpoint can accept.
            public let accept: [String]

            /// The routing keys that can be used to route messages to the service endpoint.
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

        /// The ID of the service, represented as a string.
        public let id: String

        /// The types of the service, indicated as an array of strings.
        public let type: [String]

        /// The service endpoint of the service.
        public let serviceEndpoint: [ServiceEndpoint]

        public init(
            id: String,
            type: [String],
            serviceEndpoint: [ServiceEndpoint]
        ) {
            self.id = id
            self.type = type
            self.serviceEndpoint = serviceEndpoint
        }
    }

    /// Represents a "also known as" property, which is a list of alternative names or identifiers for a Decentralized Identifier (DID) or other subject or object.
    ///
    /// The "also known as" property is typically included in a DID Document and can be used to associate the DID or subject or object with other names or identifiers.
    public struct AlsoKnownAs: DIDDocumentCoreProperty {
        /// The values of the "also known as" property, represented as an array of strings.
        public let values: [String]

        public init(values: [String]) {
            self.values = values
        }
    }

    /// Represents a "controller" property, which is a list of Decentralized Identifiers (DIDs) that control the associated DID or subject or object.
    ///
    /// The "controller" property is typically included in a DID Document and can be used to indicate who has the authority to update or deactivate the DID or subject or object.
    public struct Controller: DIDDocumentCoreProperty {
        /// The values of the "controller" property, represented as an array of DIDs.
        public let values: [DID]

        public init(values: [DID]) {
            self.values = values
        }
    }

    /// Represents a "verification methods" property, which is a list of Verification Methods associated with a Decentralized Identifier (DID) or other subject or object.
    ///
    /// The "verification methods" property is typically included in a DID Document and can be used to authenticate the identity of the DID or subject or object.
    public struct VerificationMethods: DIDDocumentCoreProperty {
        /// The values of the "verification methods" property, represented as an array of VerificationMethod structs.
        public let values: [VerificationMethod]

        public init(values: [VerificationMethod]) {
            self.values = values
        }
    }

    /// Represents a "services" property, which is a list of Services associated with a Decentralized Identifier (DID) or other subject or object.
    ///
    /// The "services" property is typically included in a DID Document and can be used to discover and interact with the associated DID or subject or object.
    public struct Services: DIDDocumentCoreProperty {
        /// The values of the "services" property, represented as an array of Service structs.
        public let values: [Service]

        public init(values: [Service]) {
            self.values = values
        }
    }

    /// Represents an "authentication" property, which is a list of URIs and Verification Methods that can be used to authenticate the associated DID or subject or object.
    ///
    /// The "authentication" property is typically included in a DID Document and can be used to verify the identity of the DID or subject or object.
    public struct Authentication: DIDDocumentCoreProperty {
        /// The URIs of the authentication property.
        public let urls: [String]

        /// The Verification Methods of the authentication property.
        public let verificationMethods: [VerificationMethod]

        public init(urls: [String], verificationMethods: [VerificationMethod]) {
            self.urls = urls
            self.verificationMethods = verificationMethods
        }
    }

    /// Represents an "assertion method" property, which is a list of URIs and Verification Methods that can be used to assert the authenticity of a message or credential associated with a DID or other subject or object.
    ///
    /// The "assertion method" property is typically included in a DID Document and can be used to verify the authenticity of messages or credentials related to the DID or subject or object.
    public struct AssertionMethod: DIDDocumentCoreProperty {
        /// The URIs of the assertion method property.
        public let urls: [String]

        /// The Verification Methods of the assertion method property.
        public let verificationMethods: [VerificationMethod]

        public init(urls: [String], verificationMethods: [VerificationMethod]) {
            self.urls = urls
            self.verificationMethods = verificationMethods
        }
    }

    /// Represents a "key agreement" property, which is a list of URIs and Verification Methods that can be used to establish a secure communication channel with a DID or other subject or object.
    ///
    /// The "key agreement" property is typically included in a DID Document and can be used to establish a secure communication channel with the DID or subject or object.
    public struct KeyAgreement: DIDDocumentCoreProperty {
        /// The URIs of the key agreement property.
        public let urls: [String]

        /// The Verification Methods of the key agreement property.
        public let verificationMethods: [VerificationMethod]

        /// Initializes the KeyAgreement struct with an array of URIs and an array of VerificationMethods.
        public init(urls: [String], verificationMethods: [VerificationMethod]) {
            self.urls = urls
            self.verificationMethods = verificationMethods
        }
    }

    /// Represents a "capability invocation" property, which is a list of URIs and Verification Methods that can be used to invoke a specific capability or service provided by a DID or other subject or object.
    ///
    /// The "capability invocation" property is typically included in a DID Document and can be used to invoke a specific capability or service provided by the DID or subject or object.
    public struct CapabilityInvocation: DIDDocumentCoreProperty {
        /// The URIs of the capability invocation property.
        public let urls: [String]

        /// The Verification Methods of the capability invocation property.
        public let verificationMethods: [VerificationMethod]

        public init(urls: [String], verificationMethods: [VerificationMethod]) {
            self.urls = urls
            self.verificationMethods = verificationMethods
        }
    }

    /// Represents a "capability delegation" property, which is a list of URIs and Verification Methods that can be used to delegate a specific capability or service provided by a DID or other subject or object to another subject or object.
    ///
    /// The "capability delegation" property is typically included in a DID Document and can be used to delegate a specific capability or service provided by the DID or subject or object.
    public struct CapabilityDelegation: DIDDocumentCoreProperty {
        /// The URIs of the capability delegation property.
        public let urls: [String]

        /// The Verification Methods of the capability delegation property.
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
