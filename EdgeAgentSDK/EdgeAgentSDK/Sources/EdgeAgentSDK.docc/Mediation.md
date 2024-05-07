# Mediation and Forward Messaging

The SDK provides a set of functionalities that enable communication between different entities through DIDs and DIDComm protocols. One of the core features of the SDK is the ability to send and receive messages, which is achieved by using the DIDComm protocol.

## DIDComm Mediation

However, the use cases for the SDK often cannot rely on the ability to have open endpoints where they can listen to incoming messages. For instance, mobile apps running on iOS or Android platforms typically cannot have an open port to listen for incoming messages.

To address this limitation, the SDK provides support for DIDComm mediation. DIDComm mediation is a mechanism that enables the communication between two parties that cannot communicate directly by routing messages through one or more mediators. This mechanism allows the SDK to work even in situations where a direct communication path is not possible.

The mediator is identified through a DID (Decentralized Identifier) that is shared between the two parties. The DID is used to send the message to the mediator, who then relays it to the recipient. The mediator can perform additional functions such as message validation, translation, or modification.

The use of a mediator in the SDK allows for the following benefits:

- __Secure communication:__ With DIDComm mediation, the SDK provides a secure way to communicate even when direct communication is not possible.
- __Flexibility:__ The use of a mediator allows the SDK to be used in a wide range of scenarios where direct communication is not possible or practical.
- __Scalability:__ The use of a mediator allows the SDK to scale to large deployments with many entities communicating with each other.

To achieve this, the mediator needs to have established a connection with both agents beforehand. Once the connection is established, the mediator can forward the message from the sending agent to the receiving agent, transparently relaying the necessary information between them.

## Forward Messaging

Forward messaging is a DIDComm message that is sent through a mediator to an intended recipient. The mediator acts as an intermediary, receiving the message from the sender, validating it, and then forwarding it to the intended recipient.

Forward messaging is useful in situations where the sender and recipient cannot communicate directly. For example, if the recipient is behind a firewall or if the recipient's IP address is not known.

In the Prism SDK, forward messaging is implemented using DIDComm mediation. The mediator receives the message, validates it, and then forwards it to the recipient. The recipient can then respond to the message, and the mediator will forward the response back to the original sender.

Forward messaging is a powerful feature that allows messages to be sent securely between two parties even if they cannot communicate directly. This makes it ideal for use in applications that require secure communication between parties with strict security requirements.

In summary, DIDComm mediation and forward messaging are essential features in the Prism SDK that enable secure communication between parties that cannot communicate directly. The mediator acts as an intermediary, receiving messages from the sender and forwarding them to the recipient. This makes it ideal for use in applications with strict security requirements that cannot rely on the ability to have open endpoints where they can listen to incoming messages.

## How to enable Forward Messaging in the SDK?

Forward messaging to a mediator is enabled by default when the mediator is running and available. To take advantage of this feature, you can create a Peer DID using the EdgeAgent with the updateMediator flag set to true. This will insert the didcommmessage service with the routingDID of the mediator into the DID.

When attempting to send a message, the Mercury library will automatically detect any forward DIDs in the service and pack a ForwardMessage with the original packed message included in its contents. This allows the message to be routed through the mediator to its intended recipient.
