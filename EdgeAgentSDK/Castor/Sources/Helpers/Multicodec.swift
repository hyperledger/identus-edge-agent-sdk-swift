import Domain
import Foundation

struct Multicodec {
    enum Codec: Int {
        case x25519 = 0xEC
        case ed25519 = 0xED

        var data: Data {
            return Data(putVarInt(Int64(self.rawValue)))
        }
    }

    enum KeyType {
        case agreement
        case authenticate
    }

    let value: Data

    init(value: Data, keyType: KeyType) {
        switch keyType {
        case .agreement:
            var buffer = Data(putUVarInt(UInt64(Codec.x25519.rawValue)))
            buffer.append(value)
            self.value = buffer
        case .authenticate:
            var buffer = Data(putUVarInt(UInt64(Codec.ed25519.rawValue)))
            buffer.append(value)
            self.value = buffer
        }
    }

    init(value: Data) {
        self.value = value
    }

    func decode(defaultCodec: Codec? = nil) throws -> (Codec, Data) {
        let (code, buffer) = try uVarInt(buffer: [UInt8](value))
        guard
            let codec = Codec(rawValue: Int(code)) else {
            throw UnknownError.somethingWentWrongError(
                customMessage: "Error while processing multicodec",
                underlyingErrors: nil
            )
        }
        return (codec, Data(buffer))
    }
}
