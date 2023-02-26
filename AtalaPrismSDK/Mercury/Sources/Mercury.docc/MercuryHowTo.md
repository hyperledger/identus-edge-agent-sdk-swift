# Mercury SDK API Tutorial

The Mercury protocol defines a set of functions for packing and sending messages. Here's a brief explanation of each function:

- `packMessage`: This function asynchronously packs a given message object into a string representation. It may throw an error if the message object is invalid.

``` swift
   // Example usage:
   let mercury = MercuryImpl(apollo: apolloImpl, castor: castorImpl, pluto: plutoImpl)
   let message = Message(...)
   do {
       let packedMessage = try mercury.packMessage(msg: message) // returns the String packed message
   } catch {
       // Handle error
   }
```

- `unpackMessage`: This function asynchronously unpacks a given string representation of a message into a message object. It may throw an error if the string is not a valid message representation.

```swift
   // Example usage:
   let mercury = MercuryImpl(apollo: apolloImpl, castor: castorImpl, pluto: plutoImpl)
   let packedMessage = "..."
   do {
       let message = try mercury.unpackMessage(msg: packedMessage) // returns the ``Message``
   } catch {
       // Handle error
   }
```

- `sendMessage`: This function asynchronously sends a given message and returns the response data. It may throw an error if the message is invalid or the send operation fails.

```swift
   // Example usage:
   let mercury = MercuryImpl(apollo: apolloImpl, castor: castorImpl, pluto: plutoImpl)
   let message = Message(...)
   do {
       let responseData = try mercury.sendMessage(msg: message)
   } catch {
       // Handle error
   }
```

- `sendMessageParseMessage`: This function asynchronously sends a given message and returns the response message object. It may throw an error if the message is invalid, the send operation fails, or the response message is invalid.

```swift
   // Example usage:
   let mercury = MercuryImpl(apollo: apolloImpl, castor: castorImpl, pluto: plutoImpl)
   let message = Domain.Message(...)
   do {
       let responseMessage = try mercury.sendMessageParseMessage(msg: message)
   } catch {
       // Handle error
   }
```
