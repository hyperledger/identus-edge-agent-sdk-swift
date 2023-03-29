# PrismAgent API Tutorial

To use the `PrismAgent`, you must first create an instance of it by passing in the necessary dependency objects and seed data. You can also use the `convenience init` to create an instance with default objects. Once you have an instance of `PrismAgent`, you can call the `start` method to start the agent and the mediator services.

```swift
let mediatorDID = DID("did:example:123")
let prismAgent = PrismAgent(seedData: nil, mediatorDID: mediatorDID)

do {
    try await prismAgent.start()
} catch {
    print("Error starting PrismAgent: \(error)")
}
```

After the PrismAgent has started, you can use the various methods and properties of the PrismAgent to interact with other agents in the network. For example, you can create a new peer DID by calling the createNewPeerDID method of the Apollo object:

```swift
let services = [Service(
    id: "#didcomm-1",
    type: ["DIDCommMessaging"],
    serviceEndpoint: [ServiceEndpoint(uri: prismAgent.mediatorRoutingDID?.string ?? "")]
)]
let peerDID = try await prismAgent.apollo.createNewPeerDID(
    seed: prismAgent.seed,
    services: services,
    updateMediator: true
)
```

To stop the PrismAgent, you can call the stop method:

```swift
do {
    try await prismAgent.stop()
} catch {
    print("Error stopping PrismAgent: \(error)")
}
```

## High-level SSI functionalities

The PrismAgent has some high-level ssi functionalities that make it easy to interact with the ledger and perform various cryptographic operations.

### DID Management

The PrismAgent provides several methods to manage DIDs:

- `createNewPrismDID`: This method creates a new Prism DID and registers it in the agent's storage. It returns the new DID.

```swift
let did = try? await agent.createNewPrismDID(
    // Add this if you want to provide a IndexPath
    // keyPathIndex: <#T##Int?#>
    // Add this if you want to provide an alias for this DID
    // alias: <#T##String?#>
    // Add any services available in the DID
    services: [ .init(
        id: "DemoID",
        type: ["DemoType"],
        serviceEndpoint: [.init(uri: "DemoServiceEndpoint")]
    )
])
```
- `registerPrismDID`: This method registers a pre-existing Prism DID in the agent's storage. It takes a `DID` object and a `keyPathIndex` used to identify the DID, and an optional `alias` that can be used to identify the DID. It assumes the seed given in the initialization was used to create the DID.

```swift
    agent.registerPrismDID(did: did, keyPathIndex: 2)
```

- `createNewPeerDID`: This method creates a new Peer DID and registers it in the agent's storage. It returns the new DID. It also takes an optional `services` array that can be used to associate services with the new DID and a `updateMediator` flag that, if `true`, will add the new DID to the mediator's key list.

```swift
    agent.createNewPeerDID(services: [
        .init(id: "demoId",
              type: ["DemoType"],
              serviceEndpoint: [.init(
                uri: "https://demo.io",
                accept: ["accept"], // Optional
                routingKeys: ["demo"]// Optional
              )])
    ], updateMediator: true)
```

- `registerPeerDID`: This method registers a pre-existing Peer DID in the agent's storage. It takes a `DID` object, an array of `privateKeys` used to sign messages, and a `updateMediator` flag that, if `true`, will add the new DID to the mediator's key list.

```swift
    let did = DID(...) // did:peer:demo
    let privateKey1 = PrivateKey(...) // Pair with the public key inside of the DID
    agent.registerPeerDID(did: did, privateKeys: [privateKey1], updateMediator: true)
```

### Signing Messages

The `signWith(did:message:)` method is used to sign messages with a DID. It takes a `DID` object and a `Data` object representing the message to sign. It returns the `Signature` object representing the signature of the message. If the DID is a Prism DID, the agent will use the corresponding key pair to sign the message. If the DID is a Peer DID, the agent will use the first private key in the `privateKeys` array associated with the DID.
