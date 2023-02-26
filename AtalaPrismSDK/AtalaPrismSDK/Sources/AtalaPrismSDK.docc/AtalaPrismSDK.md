# ``AtalaPrismSDK``

Atala PRISM Swift SDK is a library and documentation that helps developers build Apple connected SSI (self-sovereign identity) applications with Atala PRISM. This documentation will explain how to use the SDK in your project, how to prepare your development environment if you wish to contribute, and some basic considerations around the project.

### Atala PRISM

![Atala Prism Logo](logo)

Atala PRISM is a self-sovereign identity (SSI) platform and service suite for verifiable data and digital identity. Built on Cardano, it offers core infrastructure for issuing DIDs and verifiable credentials, alongside tools and frameworks to help expand your ecosystem.

## Features / APIs

Atala PRISM Swift SDK provides the following building blocks to create, manage and resolve decentralized identifiers, issue, manage and verify verifiable credentials, establish and manage trusted, peer-to-peer connections and interactions between DIDs, and store, manage, and recover verifiable data linked to DIDs.

- __Castor__: Building block that provides a suit of DID operations in a user-controlled manner.
- __Pollux__: Building block that provides a suite of credential operations in a privacy-preserving manner.
- __Mercury__: Building block that provides a set of secure, standards-based communications protocols in a transport-agnostic and interoperable manner.
- __Pluto__: Building block that provides an interface for storage operations in a portable, storage-agnostic manner.
- __Experience__: Set of commonly used operations or features that use one or multiple building blocks.

## Getting Started

### Setup

To get started with the Atala PRISM Swift SDK, you can set up the SDK and start a new project, or you can integrate the SDK in an existing project. Before you start, make sure you have the following installed on your development machine:

- Xcode 13.4 or later
- MacOS 12 or later
- iOS 13 or later

> ⚠️ **Currently you need to always open the XCode in ROSETTA mode**

### Integrating the SDK in an existing project

To integrate the SDK into an existing project, you can use the Swift Package Manager, which is distributed with Xcode.

1. Open your project in Xcode and select **File > Swift Packages > Add Package Dependency**.
2. Enter the URL for the SDK for Swift Package Manager GitHub repo (`https://github.com/input-output-hk/atala-prism-swift-sdk`) into the search bar and click **Next**.
3. You'll see the repository rules for which version of the SDK you want Swift Package Manager to install. Choose the first rule, **Version**, and select **Up to Next Minor** as it will use the latest compatible version of the dependency that can be detected from the `main` branch, then click **Next**.

### Swift Package Manager

The Swift Package Manager is a tool for managing the distribution of Swift code. It's integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

## Documentation

- [Getting Started](https://staging-docs.atalaprism.io/docs/getting-started)
- [What is identity?](https://staging-docs.atalaprism.io/docs/concepts/what-is-identity)
- [Digital wallets](https://staging-docs.atalaprism.io/docs/concepts/digital-wallets)
- [Atala PRISM Overview](https://staging-docs.atalaprism.io/docs/atala-prism/overview)
