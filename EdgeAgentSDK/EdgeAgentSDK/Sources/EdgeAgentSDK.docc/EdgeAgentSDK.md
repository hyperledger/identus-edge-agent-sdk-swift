# ``EdgeAgentSDK``

Edge Agent Swift SDK is a library and documentation that helps developers build Apple connected SSI (self-sovereign identity) applications with Identus. This documentation will explain how to use the SDK in your project, how to prepare your development environment if you wish to contribute, and some basic considerations around the project.

### Identus

Identus is a self-sovereign identity (SSI) platform and service suite for verifiable data and digital identity. Built on Cardano, it offers core infrastructure for issuing DIDs and verifiable credentials, alongside tools and frameworks to help expand your ecosystem.

## Modules / APIs

Edge Agent Swift SDK provides the following building blocks to create, manage and resolve decentralized identifiers, issue, manage and verify verifiable credentials, establish and manage trusted, peer-to-peer connections and interactions between DIDs, and store, manage, and recover verifiable data linked to DIDs.

- __<doc:ApolloHeader>__: Building block that provides a suite of cryptographic operations.
- __<doc:CastorHeader>__: Building block that provides a suite of DID operations in a user-controlled manner.
- __Pollux__: Building block that provides a suite of credential operations in a privacy-preserving manner.
- __<doc:MercuryHeader>__: Building block that provides a set of secure, standards-based communications protocols in a transport-agnostic and interoperable manner.
- __<doc:PlutoHeader>__: Building block that provides an interface for storage operations in a portable, storage-agnostic manner.
- __<doc:EdgeAgentHeader>__: EdgeAgent using all the building blocks provides an agent that can offer a set of high level DID functionalities.

## Documentation

### General information and articles

- [Getting Started](https://docs.atalaprism.io/docs/getting-started)
- [What is identity?](https://docs.atalaprism.io/docs/concepts/identity)
- [Identus Overview](https://docs.atalaprism.io/docs/atala-prism/overview)

### Architecture decision articles

- <doc:BuildingBlocks>
- <doc:TechnicalConsiderations>
- <doc:ModularApproach>
