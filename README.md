# Welcome to Atala PRISM Swift SDK

The following will explain how to use the SDK in your project, how to prepare your development environment if you wish to contribute and some basic considerations around the project.

This SDK provides a library and documentation for developers to build Apple connected SSI applications with Atala PRISM.

## Features / APIs

  * [__Castor__](WIP) Building block that will provide a suit of decentralised identifier (DID) operations to create, manage and resolve standards based decentralised identifiers in a user-controlled manner.
  * [__Pollux__](WIP) Building block that will provide a suite of credential operations to issue, manage and verify standards based verifiable credentials in a privacy preserving manner.
  * [__Mercury__](WIP) Building block that will provide a set of secure, standards based communications protocols to establish and manage trusted, peer-to-peer connections and interactions between DIDs in a transport agnostic and interoperable manner.
  * [__Pluto__](WIP) Building block that will provide an interface for storage operations to securely store, manage, and recover verifiable data linked to DIDs in a portable, storage agnostic manner.
  * [__Experience__](WIP) Set of commonly used operations or features that use 1 or multiple building blocks.

#### Table Of Contents

[How can I use the SDK on my project?](#how-can-I-use-the-SDK-on-my-project)
  * [Setup](#setup)
  * [Include the SDK on an existing application](#include-the-sdk-on-an-existing-application)
  * [Swift Package Manager](#swift-package-manager)

[Basic considerations](#basic-considerations)
  * [Atala PRISM](#atala-prism)
  * [Documentation](#documentation)

[Prepare the environment for contributing](#prepare-the-environment-for-contributing)
  * [Requirements](#requirements)
  * [Third party software](#thrid-party-software)
  * [Run Bootstrap](#run-bootstrap)

## How can I use the SDK on my project?

### Setup

To get started with the Atala PRISM Swift SDK, you can set up the SDK and start a new project, or you can integrate the SDK in an existing project.
To use the SDK you will need the following installed on your development machine:

* Xcode 13.4 or later
* MacOS 12 or later
* iOS 13 or later

### Include the SDK on an existing application

This SDK provides [Swift Package Manager](https://www.swift.org/package-manager/) to enable you to integrate easily into your project.

### Swift Package Manager

1. Swift Package Manager is distributed with Xcode. To start adding the SDK to your project, open your project in Xcode and select **File > Swift Packages > Add Package Dependency**.

1. Enter the URL for the SDK for Swift Package Manager GitHub repo (`https://github.com/input-output-hk/atala-prism-swift-sdk`) into the search bar and click **Next**.

1. You'll see the repository rules for which version of the SDK you want Swift Package Manager to install. Choose the first rule, **Version**, and select **Up to Next Minor** as it will use the latest compatible version of the dependency that can be detected from the `main` branch, then click **Next**.

## Basic considerations

### Atala PRISM

Atala PRISM is a self-sovereign identity (SSI) platform and service suite for verifiable data and digital identity. Built on Cardano, it offers core infrastructure for issuing DIDs (Decentralized identifiers) and verifiable credentials, alongside tools and frameworks to help expand your ecosystem.
The complete platform is separated in multiple repositories:

* [atala-prism-swift-sdk](--) - Repo that implements Swift platform based funcionality.
* [atala-prism-apollo](--) - Repo for the Apollo Building Block, this contains the collecion of the cryptographic methods used all around Atala PRISM.
* [atala-prism-building-blocks](https://github.com/input-output-hk/atala-prism-building-blocks) - Repo that contains the platform Building Blocks.
* [atala-prism-kmm-sdk](--) - Repo that implements Kotlin Multiplatform based funcionality.

### Documentation

The SDK will provide 2 kinds of documentation, a more general documentation describing architecture decisions and an API documentation. It will also provide within time samples on how to use the SDK. A Docx documentation will be provided for in Xcode helpful documentation as well as a website.

## Prepare the environment for contributing

If you wish to contribute for this project please have a read on [Contributing](CONTRIBUTING.md)

### Requirements

To be able to contribute to this project you will need the following software installed:

* Xcode 13.4 or later

### Third party software

This project uses Mint as a development dependency manager as well as SwiftLint, SwiftFormat and Open API.

### Run Bootstrap

By running the script [`bootstrap.sh`](https://github.com/input-output-hk/atala-prism-swift-sdk/blob/main/bootstrap.sh). A process will begin too prepare your environment for development. Installing Mint, SwiftLint, SwiftFormat and Open API. Any other environment preparation settings like creating Open API clients will also be managed automatically by this script.

This in the future will be probably replaced by Swift Package Manager Plugins.


