# [6.1.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/6.0.1...6.1.0) (2024-09-12)


### Bug Fixes

* documentation generation failure and renaming update ([1d7b906](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/1d7b906ee0e9389e0d8819d325ae59139057a639))
* issues with interoperability with other sdks ([f042691](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/f04269161d9f9769b3cdf58ce57a172a719fc691))
* update apollo library for new version and fix a test case ([4c88360](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/4c88360a2997b87d55545f9c20bdd52b6384d290))


### Features

* **agent:** add new agent derivation path ([0b302f5](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/0b302f5ab22d77e62fd759eb25c806d8cd8fdc26))
* **agent:** report problem message ([5573ef4](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/5573ef4f0d6cefa6e837d99f773605f1797a69f0))
* **agent:** revocation notification ([33d700b](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/33d700b590ad120f5939d106fdb5dca4e5316661))
* **backup:** allow backup and import of prism wallet ([e519192](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/e519192798876611b02b8c762660d968afbbfa28))
* **castor:** add capacity so you can create and resolve prism dids with ed25519 and x25519 keys ([3ec399a](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/3ec399adc6e908f421cdae671659d938ae2747d2))
* **pollux:** add anoncreds predicate on requests ([423daf4](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/423daf44b4217f0eea17aa5ff1fca39126c6b62e))
* **pollux:** add jwt credential revocation support ([3f2a698](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/3f2a6983ce948ebf5e65b13614a964cc16151bd8))
* **pollux:** add sdjwt verifier flow ([ff403aa](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/ff403aa73bdb3a323dd7636b253012c4ef5e30e0))
* **pollux:** add support for sd-jwt ([afca01b](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/afca01b281086fce118ef0ee9235e6b15c216be5))
* **sample:** add backup to sample app ([88a2312](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/88a23122cd0e34c89195d7bb402b2ebcec861f37))
* **sample:** enable sample app for anoncreds verification ([f071fe7](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/f071fe719e61b35aac3df32f240191b0a5236c36))

# [4.0.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.6.0...4.0.0) (2024-01-25)


### Bug Fixes

* bug with header and footer of ed25519 and x25519 pem keys ([8ec220f](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/8ec220f3ed7e6c3f8c00671fea3cafff486b42ab))
* didcomm connection runner message filtering ([e57d62b](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/e57d62bbdb008fde720cdb7755cf1c6a06ca631a))
* this was causing confusion since it was public, not used and did not work as expected ([b82a9d6](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/b82a9d61f27064b427a40b3cfa8f336e58937416))


### Features

* **apollo:** integrate with apollo kmm ([32bdfbd](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/32bdfbd6cc8790391254c7ec1dca8dfe01fc62ee))
* **pluto:** pluto will save link secret as a storable key. ([dbd724b](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/dbd724bca43b09394fbf282716bcd3e73459377b))
* **pollux:** add anoncreds prooving implementation ([80377b1](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/80377b1b9f6d5255e5e6f0dd896253930cf0c4ee))
* **pollux:** zkp verification ([395976a](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/395976ae984f9a7d49ef944f0ed1641ae15e4f1d))


### BREAKING CHANGES

* **apollo:** Updated Apollo public interface to be more in line with Cryptographic abstraction
* This will not affect our API or was it working, but since it was public its considered a breaking change
* **pluto:** This makes changes on pluto interface.

# [3.6.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.5.0...3.6.0) (2023-10-20)


### Features

* **castor:** remove antlr library and use regex instead ([d7b429e](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/d7b429eb46657be56bb3cbf92423baa9f9189a1a))

# [3.5.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.4.0...3.5.0) (2023-10-12)


### Features

* **anoncreds:** add support for anoncreds issuance flow ([579c603](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/579c6030eefa2cf4f9690e512bb86e86927ba20a))

# [3.4.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.3.0...3.4.0) (2023-09-27)


### Features

* provide abstraction for keychain component ([bf2e59f](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/bf2e59f9403e3459260200419aefd87ea5355f28))

# [3.3.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.2.1...3.3.0) (2023-09-04)


### Features

* **pluto:** add keychain capabilities ([f013907](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/f0139077ee6ca0a131a0db3d26906ca390fc13a4))

## [3.2.1](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.2.0...3.2.1) (2023-09-01)


### Bug Fixes

* did url string parsing correctly ([93a3eb4](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/93a3eb4a5ddfedc46b2816e38a18f56fa5b551a7))

# [3.2.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.1.0...3.2.0) (2023-08-28)


### Features

* **pollux:** add anoncreds issuance ([0d474a9](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/0d474a9e5910fa8540f0e9915e96433add543364))

# [3.1.0](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/compare/3.0.0...3.1.0) (2023-08-07)


### Bug Fixes

* typo in restoring keys ([6dc434c](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/6dc434ca316997e309c1f8250fb1c09161cc726e))


### Features

* **mediator:** add ability to decode base64 message attachment for the mediator handler ([a389894](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/a389894b198af2ea0870cace35e868431ec1f4dc))
* **pollux:** add credential abstraction ([2f76cc6](https://github.com/input-output-hk/atala-prism-wallet-sdk-swift/commit/2f76cc611a8f5abc9137c328dd427e9fbc00c32f))
