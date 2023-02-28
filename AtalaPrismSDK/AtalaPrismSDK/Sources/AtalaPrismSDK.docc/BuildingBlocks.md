# BuildingBlocks

The building blocks are the core components of Atala PRISM and they are designed to work together seamlessly to provide a comprehensive identity management solution.

## Overview

Each building block serves a specific purpose, and together they provide a solid foundation for building decentralized identity applications.

Let's take a closer look at each building block:

- [Apollo](apollo.html): Apollo is a building block that provides a suite of cryptographic operations. This includes secure hash algorithms, digital signatures, and encryption, which are all essential for creating a secure and tamper-proof identity system. Apollo ensures that all data within the Atala PRISM system is securely encrypted and digitally signed, making it resistant to tampering and unauthorized access.
- [Castor](castor.html): Castor is a building block that provides a suite of decentralized identifier (DID) operations in a user-controlled manner. DIDs are a key component of decentralized identity, as they provide a way to uniquely identify individuals and entities in a decentralized manner. Castor allows users to create, manage, and control their DIDs and associated cryptographic keys.
- [Pollux](pollux.html): Pollux is a building block that provides a suite of credential operations in a privacy-preserving manner. Credentials are a way to prove claims about an individual or entity, and they are an important part of decentralized identity. Pollux allows users to create, manage, and share credentials in a privacy-preserving way to ensure that sensitive information is not revealed.
- [Mercury](mercury.html): Mercury is a building block that provides a set of secure, standards-based communications protocols in a transport-agnostic and interoperable manner. Mercury allows different components of Atala PRISM to communicate with each other securely, using standard protocols such as HTTP, WebSocket, and MQTT.
- [Pluto](pluto.html): Pluto is a building block that provides an interface for storage operations in a portable, storage-agnostic manner. Pluto allows data to be stored and retrieved in a way that is independent of the underlying storage technology, allowing Atala PRISM to work with a variety of storage solutions.

Together, these building blocks provide a solid foundation for building decentralized identity applications that are secure, privacy-preserving, and interoperable. By using Atala PRISM, developers can focus on building innovative identity solutions without having to worry about the underlying infrastructure.

## Prism Agent

Prism Agent is a comprehensive library that brings together all the building blocks of the Prism platform - Apollo, Castor, Pluto, Mercury, and Pollux - to provide a seamless experience for developers working with decentralized identifiers (DIDs) on the Prism platform.
