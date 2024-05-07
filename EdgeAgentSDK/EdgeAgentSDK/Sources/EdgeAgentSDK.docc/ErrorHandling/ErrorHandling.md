# Error Handling

When working with SDKs, it is common to encounter errors that are specific to that SDK. These errors may be related to network connectivity, server-side errors, or invalid user inputs, among others. To handle these errors, SDKs often define custom error types that you can catch and handle in your application.

## Overview

Custom errors in Swift are typically defined using an enum. In most cases, custom errors will fall into one of two categories:

Known errors that can be identified and handled explicitly using a specific error code and message.
Unknown errors that cannot be identified explicitly but may provide additional information about the error.
To handle these errors, you need to understand the types of errors that can occur and how to handle them.

## Handling Known Errors

Known errors are errors that are specific to the SDK and are defined using an enum. These errors typically have a specific error code and message associated with them, which you can use to identify and handle the error.

To handle known errors, you need to first define a catch block that catches the error thrown by the SDK. Once you have caught the error, you can then switch on the error code to determine the specific error that occurred and take appropriate action.

Here is an example of how you can handle known errors in an SDK:

```swift
do {
    let result = try agent.doSomething()
    // Do something with the result
} catch let error as KnownSDKError {
    switch error.code {
    case 100:
        // Handle error 100
        break
    case 101:
        // Handle error 101
        break
    default:
        // Handle any other error
        break
    }
} catch {
    // Handle any other error
}
```

In the example above, we catch errors thrown by the SDK and switch on the error code to determine the specific error that occurred. Depending on the error code, we take appropriate action, such as showing an error message to the user or retrying the operation.

## Handling Unknown Errors

Unknown errors are errors that cannot be identified explicitly but may provide additional information about the error. These errors typically provide a message that describes the error and may contain one or more underlying errors that caused the error.

To handle unknown errors, you need to first define a catch block that catches the error thrown by the SDK. Once you have caught the error, you can then check if the error conforms to the UnknownSDKError protocol, which defines the properties code, message, and underlyingErrors. You can use these properties to provide additional information about the error and take appropriate action.

Here is an example of how you can handle unknown errors in an SDK:

```swift
do {
    let result = try agent.doSomething()
    // Do something with the result
} catch let error as UnknownSDKError {
    if let code = error.code {
        // Handle error with code
    }
    if let message = error.message {
        // Handle error with message
    }
    if let underlyingErrors = error.underlyingErrors {
        // Handle any underlying errors
    }
} catch {
    // Handle any other error
}
```

## Common Errors

This is an enum definition named `CommonError` that conforms to the `KnownPrismError` protocol. The enum has two cases, and each case represents an error scenario with a message that describes the reason for the error.

### Error 1: Invalid URL

This error occurs when an invalid URL is encountered while trying to send a message. The reason for this error could be due to the following possible reasons:

- The URL is not in the correct format.
- The URL is not valid.

The recovery solutions for this error are:

- Verify if the URL is in the correct format.
- Check if the URL is valid.

### Error 2: HTTP Error

This error occurs when an HTTP error is encountered while trying to send a message. The reason for this error could be due to the following possible reasons:

- The HTTP response code is not successful.
- There is an issue with the message.

The recovery solutions for this error are:

- Verify the HTTP response code.
- Check if there is an issue with the message.

## Topics

### Errors

- <doc:EdgeAgentErrors>
- <doc:ApolloErrors>
- <doc:CastorErrors>
- <doc:MercuryErrors>
- <doc:PlutoErrors>
