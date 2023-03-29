# Welcome to Atala PRISM Swift SDK

The following will explain how to use the SDK in your project, how to prepare your development environment if you wish to contribute and some basic considerations around the project.

This SDK provides a library and documentation for developers to build Apple connected SSI applications with Atala PRISM.

## Basic considerations

### Atala PRISM

Atala PRISM is a self-sovereign identity (SSI) platform and service suite for verifiable data and digital identity. Built on Cardano, it offers core infrastructure for issuing DIDs (Decentralized identifiers) and verifiable credentials, alongside tools and frameworks to help expand your ecosystem.
The complete platform is separated in multiple repositories:

* [atala-prism-wallet-sdk-swift]() - Repo that implements Atala PRISM for Apple platforms in Swift.
* [atala-prism-wallet-sdk-ts](https://github.com/input-output-hk/atala-prism-wallet-sdk-ts) - Repo that implements Atala PRISM for Browser and NodeJS platforms in Typescript.
* [atala-prism-building-blocks](https://github.com/input-output-hk/atala-prism-building-blocks) - Repo that contains the platform Building Blocks.

### Modules / APIs

Atala PRISM Swift SDK provides the following building blocks to create, manage and resolve decentralized identifiers, issue, manage and verify verifiable credentials, establish and manage trusted, peer-to-peer connections and interactions between DIDs, and store, manage, and recover verifiable data linked to DIDs.

* __Apollo__: Building block that provides a suite of criptographic operations.
* __Castor__: Building block that provides a suite of DID operations in a user-controlled manner.
* __Pollux__: Building block that provides a suite of credential operations in a privacy-preserving manner.
* __Mercury__: Building block that provides a set of secure, standards-based communications protocols in a transport-agnostic and interoperable manner.
* __Pluto__: Building block that provides an interface for storage operations in a portable, storage-agnostic manner.
* __PrismAgent__: PrismAgent using all the building blocks provides a agent that can provide a set of high level SSI functionalities.

## Getting Started

### Setup

To get started with the Atala PRISM Swift SDK, you can set up the SDK and start a new project, or you can integrate the SDK in an existing project. Before you start, make sure you have the following installed on your development machine:

- Xcode 13.4 or later
- MacOS 12 or later
- iOS 15 or later

### Integrating the SDK in an existing project

To integrate the SDK into an existing project, you can use the Swift Package Manager, which is distributed with Xcode.

1. Open your project in Xcode and select **File > Swift Packages > Add Package Dependency**.
2. Enter the URL for the SDK for Swift Package Manager GitHub repo (`https://github.com/input-output-hk/atala-prism-wallet-sdk-swift`) into the search bar and click **Next**.
3. You'll see the repository rules for which version of the SDK you want Swift Package Manager to install. Choose the first rule, **Version**, and select **Up to Next Minor** as it will use the latest compatible version of the dependency that can be detected from the `main` branch, then click **Next**.

### Swift Package Manager

The Swift Package Manager is a tool for managing the distribution of Swift code. It's integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.
