# PrismAgent Errors

This is an enum definition named `PrismAgentError` that conforms to the `KnownPrismError` protocol. The enum has several cases, and each case represents an error scenario with a message that describes the reason for the error.

### Error 1: Cannot Find DID Key Pair Index

This error occurs when trying to sign a DID, but the key pair index cannot be found. The reason for this error could be due to the following possible reasons:

- The key pair is not registered.
- There is a bug in the code.

The recovery solutions for this error are:

- Verify if the key pair is registered.
- Check if there is a bug in the code.

### Error 2: Invitation Is Invalid

This error occurs when the invitation cannot be parsed, and the message/JSON is invalid. The reason for this error could be due to the following possible reasons:

- The invitation message/JSON is not formatted correctly.
- The invitation message/JSON is not valid.

The recovery solutions for this error are:

- Verify if the invitation message/JSON is formatted correctly.
- Check if the invitation message/JSON is valid.

### Error 3: Unknown Invitation Type

This error occurs when the type of invitation is not supported. The reason for this error could be due to the following possible reasons:

- The type of invitation is not recognized.
- The type of invitation is not valid.

The recovery solutions for this error are:

- Verify if the type of invitation is recognized.
- Check if the type of invitation is valid.

### Error 4: Invalid Message Type

This error occurs when the message type is invalid. The reason for this error could be due to the following possible reasons:

- The message type does not represent the protocol.
- The message type does not have "from" and "to" fields.

The recovery solutions for this error are:

- Verify if the message type represents the protocol.
- Check if the message type has "from" and "to" fields.

### Error 5: No Mediator Available

This error occurs when there is no mediator available. The reason for this error could be due to the following possible reasons:

- The mediator is not set up.
- The mediator is not available.

The recovery solutions for this error are:

- Verify if the mediator is set up.
- Check if the mediator is available.

### Error 6: Mediation Request Failed

This error occurs when the mediation request fails. The reason for this error could be due to the following possible reasons:

- There are underlying errors.
- The mediation handler is not set up.

The recovery solutions for this error are:

- Verify if there are underlying errors.
- Check if the mediation handler is set up.
