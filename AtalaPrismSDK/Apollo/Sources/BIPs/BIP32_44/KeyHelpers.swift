import Foundation
import secp256k1

struct KeyHelpers {
    static func computePublicKey(fromPrivateKey privateKey: Data, compression: Bool) -> Data {
        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
            return Data()
        }
        defer { secp256k1_context_destroy(ctx) }
        var pubkey = secp256k1_pubkey()
        var seckey: [UInt8] = privateKey.map { $0 }
        if seckey.count != 32 {
            return Data()
        }
        if secp256k1_ec_pubkey_create(ctx, &pubkey, &seckey) == 0 {
            return Data()
        }
        if compression {
            var serializedPubkey = [UInt8](repeating: 0, count: 33)
            var outputlen = 33
            if secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &outputlen, &pubkey, UInt32(SECP256K1_EC_COMPRESSED)) == 0 {
                return Data()
            }
            if outputlen != 33 {
                return Data()
            }
            return Data(serializedPubkey)
        } else {
            var serializedPubkey = [UInt8](repeating: 0, count: 65)
            var outputlen = 65
            if secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &outputlen, &pubkey, UInt32(SECP256K1_EC_UNCOMPRESSED)) == 0 {
                return Data()
            }
            if outputlen != 65 {
                return Data()
            }
            return Data(serializedPubkey)
        }
    }

    static func compressPublicKey(fromPublicKey publicKey: Data) -> Data {
        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
            return Data()
        }
        defer { secp256k1_context_destroy(ctx) }
        var pubkey = secp256k1_pubkey()
        var input: [UInt8] = publicKey.map { $0 }
        if secp256k1_ec_pubkey_parse(ctx, &pubkey, &input, input.count) == 0 {
            return Data()
        }
        var serializedPubkey = [UInt8](repeating: 0, count: 33)
        var outputlen = 33
        if secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &outputlen, &pubkey, UInt32(SECP256K1_EC_COMPRESSED)) == 0 {
            return Data()
        }
        if outputlen != 33 {
            return Data()
        }
        return Data(serializedPubkey)
    }

    static func uncompressPublicKey(fromPublicKey publicKey: Data) -> Data {
        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
            return Data()
        }
        defer { secp256k1_context_destroy(ctx) }
        var pubkey = secp256k1_pubkey()
        var input: [UInt8] = publicKey.map { $0 }
        if secp256k1_ec_pubkey_parse(ctx, &pubkey, &input, input.count) == 0 {
            return Data()
        }
        var serializedPubkey = [UInt8](repeating: 0, count: 65)
        var outputlen = 65
        if secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &outputlen, &pubkey, UInt32(SECP256K1_EC_UNCOMPRESSED)) == 0 {
            return Data()
        }
        if outputlen != 65 {
            return Data()
        }
        return Data(serializedPubkey)
    }

//        if compression {
//            var serializedPubkey = [UInt8](repeating: 0, count: 33)
//            var outputlen = 33
//            if secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &outputlen, &pubkey, UInt32(SECP256K1_EC_COMPRESSED)) == 0 {
//                return Data()
//            }
//            if outputlen != 33 {
//                return Data()
//            }
//            return Data(serializedPubkey)
//        } else {
//            var serializedPubkey = [UInt8](repeating: 0, count: 65)
//            var outputlen = 65
//            if secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &outputlen, &pubkey, UInt32(SECP256K1_EC_UNCOMPRESSED)) == 0 {
//                return Data()
//            }
//            if outputlen != 65 {
//                return Data()
//            }
//            return Data(serializedPubkey)
//        }
//    }
}
