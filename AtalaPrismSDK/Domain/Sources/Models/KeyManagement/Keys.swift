import Foundation

public protocol Key {
    var keyType: String { get }
    var keySpecifications: [String: String] { get }
    var size: Int { get }
    var raw: Data { get }
}

public protocol PrivateKey: Key {
    func publicKey() -> PublicKey
}

public protocol PublicKey: Key {
    func verify(data: Data, signature: Data) async throws -> Bool
}

public extension Key {
    func getProperty(_ spec: KeyProperties) -> String? {
        self.keySpecifications[spec.rawValue]
    }
}
