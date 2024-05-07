# Technical Considerations

The architecture of the SDK is a result of a careful evaluation of different software development methodologies and patterns. We chose a modular, clean architecture that is based on protocol-oriented programming and domain-oriented programming principles, as well as dependency injection, for several reasons.

## Overview

### Modular Clean Architecture

Modular clean architecture is a software development methodology that emphasizes the separation of concerns and the creation of independent modules that can be easily tested and maintained. This approach promotes the use of small, reusable components that can be combined in different ways to create larger systems. The SDK architecture uses this approach to ensure that each module can be developed and tested independently, reducing the risk of bugs and improving the overall quality of the code.

### Protocol-Oriented Programming

Protocol-oriented programming is a programming paradigm that focuses on the behavior of objects, rather than their structure. This approach promotes the use of protocols to define the behavior of objects, allowing for more flexible and extensible code. The SDK architecture uses this approach to ensure that the different modules can work together seamlessly, regardless of the underlying implementation details.

### Domain-Oriented Programming

Domain-oriented programming is a programming paradigm that focuses on the domain-specific requirements of a system, rather than the technical details of the implementation. This approach promotes the use of domain-specific models and concepts, which can be used to simplify the development process and improve the maintainability of the code. The SDK architecture uses this approach to ensure that the different modules are designed around the specific needs of decentralized identity management, making it easier for developers to build decentralized applications that are secure and scalable.

### Dependency Injection

Dependency injection is a programming pattern that promotes loose coupling between different components of a system. This approach promotes the use of interfaces and dependency injection containers to ensure that each component can be developed and tested independently, without relying on the implementation details of other components. The SDK architecture uses this approach to ensure that each module can be developed and tested independently, making it easier for developers to add new functionality to the system without affecting the existing code.

## Topics

- <doc:ModularApproach>
- <doc:BuildingBlocks>
