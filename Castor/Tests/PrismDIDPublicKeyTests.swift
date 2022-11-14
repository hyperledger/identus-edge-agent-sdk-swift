import Apollo
@testable import Castor
import Domain
import SwiftProtobuf
import XCTest

final class PrismDIDPublicKeyTests: XCTestCase {
    var seed: Seed!
    var keyPair: KeyPair!
    var apollo: Apollo!

    override func setUp() async throws {
        apollo = ApolloImpl()
        seed = apollo.createRandomSeed().seed
        keyPair = apollo.createKeyPair(seed: seed, index: 0)
    }

    func testFromProto() throws {
        let publicKey = PrismDIDPublicKey(
            apollo: apollo,
            id: PrismDIDPublicKey.Usage.masterKey.id(index: 0),
            usage: .masterKey,
            keyData: keyPair.publicKey
        )

        let protoData = try publicKey.toProto().serializedData()
        let proto = try Io_Iohk_Atala_Prism_Protos_PublicKey(serializedData: protoData)
        let parsedPublicKey = try PrismDIDPublicKey(apollo: apollo, proto: proto)
        XCTAssertEqual(parsedPublicKey.id, "master0")
        XCTAssertEqual(parsedPublicKey.keyData.value, publicKey.keyData.value)
        XCTAssertEqual(parsedPublicKey.usage, publicKey.usage)
    }
}
