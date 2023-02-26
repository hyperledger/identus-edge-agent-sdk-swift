# Mercury Errors

This is an enum definition named `MercuryError` that conforms to `KnownPrismError` protocol. The enum has several cases, and each case represents an error scenario with a message that describes the reason for the error.

### Error 1: No Recipient DID Set

This error occurs when there is no recipient set in the message. The reason for this error could be due to the following possible reasons:

- The recipient is not set.
- The recipient value is not valid.

The recovery solutions for this error are:

- Verify if the recipient is set.
- Check if the recipient value is valid.

### Error 2: No Valid Service Found

This error occurs when there are no valid services found for a specific DID. The reason for this error could be due to the following possible reasons:

- There are no valid services found for the DID.
- The DID is not valid.

The recovery solutions for this error are:

- Verify if there are valid services available for the DID.
- Check if the DID is valid.

### Error 3: No Sender DID Set

This error occurs when there is no sender set in the message. The reason for this error could be due to the following possible reasons:

- The sender is not set.
- The sender value is not valid.

The recovery solutions for this error are:

- Verify if the sender is set.
- Check if the sender value is valid.

### Error 4: Unknown Attachment Data Type

This error occurs when an unknown AttachmentData type is found while decoding a message. The reason for this error could be due to the following possible reasons:

- The AttachmentData type is unknown.
- The AttachmentData format is invalid.

The recovery solutions for this error are:

- Verify if the AttachmentData type is known.
- Check if the AttachmentData format is valid.

### Error 5: Message Attachment Without ID

This error occurs when decoding a message, and a message attachment is found without an "id" value, which is invalid. The reason for this error could be due to the following possible reasons:

- The message attachment does not have an "id" value.
- The message attachment format is invalid.

The recovery solutions for this error are:

- Verify if the message attachment has an "id" value.
- Check if the message attachment format is valid.

### Error 6: Message Invalid Body Data

This error occurs when decoding a message, and the message body is found to be invalid. The reason for this error could be due to the following possible reasons:

- The message body is not valid.
- The message body format is invalid.

The recovery solutions for this error are:

- Verify if the message body is valid.
- Check if the message body format is valid.

### Error 7: DIDComm Error

This error occurs when there is an error in the DIDComm protocol. The reason for this error could be due to the following possible reasons:

- There is an issue with the DIDComm protocol.
- The message is not valid.
- DIDComm could not find secrets (did private keys) to pack the message.

The recovery solutions for this error are:

- Verify if there is an issue with the DIDComm protocol.
- Check if the message is valid.
- Check if the secret resolver is finding and providing the secrets.
