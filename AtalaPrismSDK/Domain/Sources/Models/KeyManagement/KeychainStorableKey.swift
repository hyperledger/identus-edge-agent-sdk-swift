import Foundation
import Security

/// Represents properties required for storing keys in a keychain.
public struct KeychainStorableKeyProperties {

    /// Represents the type of cryptographic key.
    public enum KeyType: String {
        case privateKey
        case publicKey
    }

    /// Represents the accessibility of the key in the keychain.
    public enum Accessability {

        /// Key is accessible after the first device unlock.
        /// - Parameter deviceOnly: A boolean indicating if the key is available only on the specific device.
        case firstUnlock(deviceOnly: Bool)

        /// Key is accessible as long as the device is unlocked.
        /// - Parameter deviceOnly: A boolean indicating if the key is available only on the specific device.
        case unlocked(deviceOnly: Bool)

        /// Key is accessible when a password is set.
        case passwordSet

        /// Indicates if the key is available only on the specific device.
        var deviceOnly: Bool {
            switch self {
            case .firstUnlock(let deviceOnly):
                return deviceOnly
            case .unlocked(let deviceOnly):
                return deviceOnly
            case .passwordSet:
                return true
            }
        }
    }

    /// Represents the cryptographic algorithm of the key.
    public enum KeyAlgorithm: String {
        /// RSA is an asymmetric algorithm used for both encryption and digital signatures.
        case rsa

        /// DSA (Digital Signature Algorithm) is primarily used for digital signatures.
        case dsa

        /// AES (Advanced Encryption Standard) is a symmetric encryption algorithm.
        case aes

        /// DES (Data Encryption Standard) is an older symmetric encryption algorithm that's considered insecure today.
        case des

        /// 3DES (Triple DES) is an enhancement of DES that applies the DES algorithm three times on each data block. It's represented as "3des" in the string.
        case _3des = "3des"

        /// RC4 is a symmetric stream cipher.
        case rc4

        /// RC2 is a symmetric block cipher.
        case rc2

        /// CAST is a family of symmetric encryption algorithms.
        case cast

        /// EC (Elliptic Curve) is used in asymmetric cryptography for encryption, digital signatures, and key agreement.
        case ec

        /// Represents a `kSecAttrKeyClassKey`. It's a key type that doesn't leverage the `SecKey` API for cryptographic operations. This can be thought of as a raw representation of a key, without being tied to specific cryptographic operations or algorithms.
        case rawKey

        /// A generic password representation, not associated with any specific cryptographic algorithm.
        case genericPassword
    }
}

/// Protocol defining a key that can be stored within the keychain.
///
/// This protocol extends the basic `StorableKey` interface to include properties specific to the keychain. It provides information about the cryptographic algorithm used (`type`), the key type (`keyClass`), accessibility restrictions (`accessibility`), and whether or not the key is synchronizable across the user's devices (`synchronizable`).
public protocol KeychainStorableKey: StorableKey {

    /// The cryptographic algorithm used by the key.
    ///
    /// This determines how the key is used for cryptographic operations. For example, the key could be based on the RSA algorithm, the AES algorithm, etc. This attribute is aligned with Apple's `kSecAttrKeyType`.
    var type: KeychainStorableKeyProperties.KeyAlgorithm { get }

    /// The class or type of the key.
    ///
    /// Specifies if the key is a public key, private key, or a symmetric key. This attribute helps determine how the key interacts within cryptographic operations.
    var keyClass: KeychainStorableKeyProperties.KeyType { get }

    /// The accessibility of the key within the keychain.
    ///
    /// Determines under which conditions the key can be accessed. This might restrict access to the key until the device has been unlocked for the first time or every time the device is unlocked, for instance. It provides a layer of security by defining when the key can be accessed.
    var accessiblity: KeychainStorableKeyProperties.Accessability? { get }

    /// Indicates if the key is synchronizable across devices using iCloud.
    ///
    /// If `true`, the key can be synchronized and made available on other devices signed into the same Apple ID. This is useful for shared secrets that need to be available across a user's devices. However, developers must be careful about what is synchronized to ensure user privacy and security.
    var synchronizable: Bool { get }
}

/// Extension of the `Key` protocol to provide additional functionality related to keychain storage.
public extension Key {
    /// A boolean value indicating whether the key can be stored in the keychain.
    var isKeychainStorable: Bool { self is KeychainStorableKey }

    /// Returns this key as a `KeychainStorableKey`, or `nil` if the key cannot be stored in the keychain.
    var keychainStorable: KeychainStorableKey? { self as? KeychainStorableKey }
}
