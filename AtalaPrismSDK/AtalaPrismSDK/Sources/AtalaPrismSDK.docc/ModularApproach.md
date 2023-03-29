# Modular Approach

A modular approach is an essential part of the Atala PRISM architecture. It allows each building block to operate independently of each other, reducing indirect dependencies between components. To achieve this, Atala PRISM uses protocols-oriented programming, domain-oriented programming, and dependency injection.

## Overview

For example, Castor, which provides decentralized identifier (DID) operations, depends on the Apollo protocol for cryptographic operations. However, it doesn't depend on the Apollo implementation or module directly. Instead, it depends on the Domain module, which defines the Apollo protocol. This separation of concerns allows for better maintainability and flexibility of the Atala PRISM architecture.

The Atala PRISM SDK provides implementations for each of the building blocks, but the architecture decision was made to allow developers to create their own implementations of a building block. This means that developers can customize and extend the functionality of the building blocks to suit their specific needs.

For instance, Pluto is the storage module within the Atala PRISM SDK, and its implementation uses CoreData and Keychain to securely store data. However, if a developer wants to use their own implementation of Pluto, they can do so and still use the rest of the SDK. This approach allows developers to choose the storage solution that best suits their use case, without being tied to a specific implementation within the Atala PRISM SDK.

Overall, the modular approach of Atala PRISM architecture provides developers with flexibility, extensibility, and maintainability, allowing them to create innovative decentralized identity solutions with ease.

Adding an diagram explaining how the different components leverage each other would be helpful. (eg: apollo uses castor)