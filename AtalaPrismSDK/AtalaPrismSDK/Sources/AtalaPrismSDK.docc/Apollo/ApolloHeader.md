# Apollo

Apollo is a suite of cryptographic primitives designed to ensure the integrity, authenticity, and confidentiality of any data that is stored and processed. These primitives provide a provably secure way to protect sensitive information, and they can be used in a wide range of applications.

## Cryptographic Primitives for Data Security

### Hashing

One of the basic building blocks of cryptography is the cryptographic hash, which is used to ensure the integrity of data. Hashing is frequently used to build more complex schemes, such as Merkle trees or digital signatures. Hashes can be used on their own to ensure the integrity of large chunks of data or as a basic commitment scheme.

### Digital Signatures

Digital signatures are the equivalent of handwritten signatures in the digital world. Owners of private signing keys create signatures, and anyone can check their validity with the corresponding public verification key. Most credentials carry a signature by their issuer. Digital signatures are used to ensure the authenticity and integrity of data.

### Symmetric Encryption

Symmetric encryption allows parties to exchange information while maintaining its secrecy. Given a symmetric key shared between parties, they can communicate securely. Symmetric encryption is a basic component for building secure communication channels.

### Public-Key Encryption

Public-key encryption uses a public encryption key to encrypt data so that only the owner of the corresponding private key can decrypt it. Public-key encryption is mostly used to encrypt symmetric keys or other (short) cryptographic values because of the high computational costs.

### Accumulators

Cryptographic accumulators allow for the accumulation of multiple values into one. Merkle trees are the most common type of accumulators used in the cryptocurrency domain. Accumulators make it possible to check (and prove) whether a given value has been accumulated or not.

### MAC

Message Authentication Codes are a type of symmetric equivalent of digital signatures. If two users share a symmetric key, they can use MAC algorithms to ensure the authenticity of the messages they exchange. The main difference between MACs and digital signatures is that MACs do not provide non-repudiation.

### Key Exchange

Key exchange protocols enable two or more parties to securely negotiate a symmetric key, even if they only know each other’s public keys. Key exchange protocols are used to establish secure communication channels.

By using the Apollo suite of cryptographic primitives, developers can build secure and provably secure applications that protect sensitive data from unauthorized access, tampering, or theft.

## Topics

### Tutorials

- <doc:ApolloTutorials>

### Errors

- <doc:ApolloErrors>
