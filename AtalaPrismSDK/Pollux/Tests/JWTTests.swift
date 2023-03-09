import Apollo
import Castor
import Domain
import CryptoKit
@testable import Pollux
import XCTest
import secp256k1

final class JWTTests: XCTestCase {

    lazy var apollo = ApolloImpl()
    lazy var castor = CastorImpl(apollo: apollo)

    func testXXX() {
        let unbased = Data(
            fromBase64URL:"4rkmmfCLyOfA-ym_f5aFIU7Sh3TXJKlF5__WHcFapPbUbP83PfcWa3LNQQzKRpQ6V4iSWkugHWtDaNCjthmmww"
        )!
        print(unbased.base64Encoded())
    }

    func testJWTVerification() async throws {
        let credential = "eyJhbGciOiJFUzI1NksifQ.eyJpc3MiOiJkaWQ6cHJpc206MWE0ZWVkN2E2YzViM2IzYzE4NDVkMGQyMTI3MWEwMjU5NzY5NzhkYjRlZDY1NDc2MTQwNTAwMDU2NGZjYWIwMTpDc1lCQ3NNQkVtTUtEbTE1TFdsemMzVnBibWN0YTJWNUVBSkNUd29KYzJWamNESTFObXN4RWlBOVZnT29QbVAxZGpEdG5NY1EwejhNTHVSZENackxUOXVXbHJWQkdKc0RfeG9ndGNhd3JtbFRybUNWalJzR2R2Sm1fQUFIeUhMZUlSQ0oyQzU5Y0N1Q3p5TVNYQW9IYldGemRHVnlNQkFCUWs4S0NYTmxZM0F5TlRack1SSWcyV2tGVjdGVy1YeGJvbEZYVHVmQ202MWFoSjdDMjBzTFp4MEloUnJUU0ZZYUlFeXVadERVcGpCVEdYUi10ZHBWWjJwTG5KMjZZckJOQVM3OEJwQlNySVc2Iiwic3ViIjoiZGlkOnByaXNtOjY4OGYxMGJmMWZmZDcxZTdmYmY2MGYwYTE2Njg4OTMzZGZjOGY5OTgzMWIwMzFlMzE1NDk0MDU2NWI5MTEzN2U6Q3NNQkNzQUJFbUFLQzIxNUxXRjFkR2d0YTJWNUVBUkNUd29KYzJWamNESTFObXN4RWlCUXd1TFpyaGxLWF9GWUNYRnh3R2FDTWFwc0FhX1Zaamx1V2pHYTNWc1VPUm9nUXJON1QwRWd1UlhmNDBYbEdkWllHYWF4UVZxRkdBY0Q3SzRiT3JzQUs1OFNYQW9IYldGemRHVnlNQkFCUWs4S0NYTmxZM0F5TlRack1SSWd2LVBTazZ2VVFTVG5qbDFSQ3BzS1N0UXhfQkNJQ1dudlhNdjB2MHp6TWFjYUlGdmx6bzVJOVVnOUloUXN5NHB0bzVMaURYWG9uMUx3X0JsUldXdXgzUklwIiwibmJmIjoxNjc4NDQ4NDA3LCJleHAiOjE2Nzg0NTIwMDcsInZjIjp7ImNyZWRlbnRpYWxTdWJqZWN0Ijp7ImZpcnN0bmFtZSI6IkFsaWNlIiwiYmlydGhkYXRlIjoiMDFcLzAxXC8yMDAwIiwiaWQiOiJkaWQ6cHJpc206Njg4ZjEwYmYxZmZkNzFlN2ZiZjYwZjBhMTY2ODg5MzNkZmM4Zjk5ODMxYjAzMWUzMTU0OTQwNTY1YjkxMTM3ZTpDc01CQ3NBQkVtQUtDMjE1TFdGMWRHZ3RhMlY1RUFSQ1R3b0pjMlZqY0RJMU5tc3hFaUJRd3VMWnJobEtYX0ZZQ1hGeHdHYUNNYXBzQWFfVlpqbHVXakdhM1ZzVU9Sb2dRck43VDBFZ3VSWGY0MFhsR2RaWUdhYXhRVnFGR0FjRDdLNGJPcnNBSzU4U1hBb0hiV0Z6ZEdWeU1CQUJRazhLQ1hObFkzQXlOVFpyTVJJZ3YtUFNrNnZVUVNUbmpsMVJDcHNLU3RReF9CQ0lDV252WE12MHYwenpNYWNhSUZ2bHpvNUk5VWc5SWhRc3k0cHRvNUxpRFhYb24xTHdfQmxSV1d1eDNSSXAiLCJsYXN0bmFtZSI6IldvbmRlcmxhbmQifSwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCJdLCJAY29udGV4dCI6WyJodHRwczpcL1wvd3d3LnczLm9yZ1wvMjAxOFwvY3JlZGVudGlhbHNcL3YxIl19fQ.4rkmmfCLyOfA-ym_f5aFIU7Sh3TXJKlF5__WHcFapPbUbP83PfcWa3LNQQzKRpQ6V4iSWkugHWtDaNCjthmmww"

        let result = try await VerifyJWTCredential(
            apollo: apollo,
            castor: castor,
            jwtString: credential
        ).compute()
        // For some reason this XCAssert takes a few seconds to process but the compute function above is quick.
        XCTAssertTrue(result)
    }

//    func testP256() async throws {
//        let header = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9"
//        let claims = "eyJpc3MiOiJodHRwczovL2V4YW1wbGUuZWR1L2lzc3VlcnMvNTY1MDQ5Iiwic3ViIjoiMSIsInZjIjp7IkBjb250ZXh0IjpbImh0dHBzOi8vd3d3LnczLm9yZy8yMDE4L2NyZWRlbnRpYWxzL3YxIiwiaHR0cHM6Ly93d3cudzMub3JnLzIwMTgvY3JlZGVudGlhbHMvZXhhbXBsZXMvdjEiXSwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsIlVuaXZlcnNpdHlEZWdyZWVDcmVkZW50aWFsIl0sImNyZWRlbnRpYWxTY2hlbWEiOnsiaWQiOiJkaWQ6d29yazpNRFA4QXNGaEh6aHdVdkdOdVlrWDdUO2lkPTA2ZTEyNmQxLWZhNDQtNDg4Mi1hMjQzLTFlMzI2ZmJlMjFkYjt2ZXJzaW9uPTEuMCIsInR5cGUiOiJKc29uU2NoZW1hVmFsaWRhdG9yMjAxOCJ9LCJjcmVkZW50aWFsU3ViamVjdCI6eyJpZCI6IjEiLCJ1c2VyTmFtZSI6IkJvYiIsImFnZSI6NDIsImVtYWlsIjoiZW1haWwifSwiY3JlZGVudGlhbFN0YXR1cyI6eyJpZCI6ImRpZDp3b3JrOk1EUDhBc0ZoSHpod1V2R051WWtYN1Q7aWQ9MDZlMTI2ZDEtZmE0NC00ODgyLWEyNDMtMWUzMjZmYmUyMWRiO3ZlcnNpb249MS4wIiwidHlwZSI6IkNyZWRlbnRpYWxTdGF0dXNMaXN0MjAxNyJ9LCJyZWZyZXNoU2VydmljZSI6eyJpZCI6Imh0dHBzOi8vZXhhbXBsZS5lZHUvcmVmcmVzaC8zNzMyIiwidHlwZSI6Ik1hbnVhbFJlZnJlc2hTZXJ2aWNlMjAxOCJ9fSwibmJmIjoxMjYyMzA0MDAwLCJleHAiOjEyNjMyNTQ0MDAsImp0aSI6Imh0dHA6Ly9leGFtcGxlLmVkdS9jcmVkZW50aWFscy8zNzMyIn0"
//
//        let signed = header + "." + claims
//        let signatureString = "AZD7eIiViuCLZDMstEl-cTii1KoJiST9oiX2zp9NJoOMNg_nKKmiibrJWTenkYddpwhUsmewH8gai5tZpVD1Qw"
//
//
//        let x = Data(fromBase64URL: "F5xVZcrclYgG6oRH3fSw45cN0JUt-scKFSZK1J2HTCM")!
//        let y = Data(fromBase64URL: "oEUSqNoiiCOkUMzgJ_6gjv-vvTnl-g5gYUaT8dB2nGQ")!
//        let pubKeyData = x + y
//        let pubKey = try P256.Signing.PublicKey(rawRepresentation: pubKeyData)
//
//        let signature = try P256.Signing.ECDSASignature(rawRepresentation: Data(fromBase64URL: signatureString)!)
//        let hash = SHA256.hash(data: signed.data(using: .utf8)!)
//        XCTAssertTrue(pubKey.isValidSignature(signature, for: hash))
//    }

    func testVerifyJWTSignature() throws {
        let header = "eyJhbGciOiJFUzI1NksifQ"
        let claims = "eyJzdWIiOiIxIiwibmJmIjoxMjYyMzA0MDAwLCJpc3MiOiJodHRwczovL2V4YW1wbGUuZWR1L2lzc3VlcnMvNTY1MDQ5IiwiZXhwIjoxMjYzMjU0NDAwLCJ2YyI6eyJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vd3d3LnczLm9yZy8yMDE4L2NyZWRlbnRpYWxzL2V4YW1wbGVzL3YxIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJVbml2ZXJzaXR5RGVncmVlQ3JlZGVudGlhbCJdLCJjcmVkZW50aWFsU2NoZW1hIjp7ImlkIjoiZGlkOndvcms6TURQOEFzRmhIemh3VXZHTnVZa1g3VDtpZD0wNmUxMjZkMS1mYTQ0LTQ4ODItYTI0My0xZTMyNmZiZTIxZGI7dmVyc2lvbj0xLjAiLCJ0eXBlIjoiSnNvblNjaGVtYVZhbGlkYXRvcjIwMTgifSwiY3JlZGVudGlhbFN1YmplY3QiOnsiaWQiOiIxIiwidXNlck5hbWUiOiJCb2IiLCJhZ2UiOjQyLCJlbWFpbCI6ImVtYWlsIn0sImNyZWRlbnRpYWxTdGF0dXMiOnsiaWQiOiJkaWQ6d29yazpNRFA4QXNGaEh6aHdVdkdOdVlrWDdUO2lkPTA2ZTEyNmQxLWZhNDQtNDg4Mi1hMjQzLTFlMzI2ZmJlMjFkYjt2ZXJzaW9uPTEuMCIsInR5cGUiOiJDcmVkZW50aWFsU3RhdHVzTGlzdDIwMTcifSwicmVmcmVzaFNlcnZpY2UiOnsiaWQiOiJodHRwczovL2V4YW1wbGUuZWR1L3JlZnJlc2gvMzczMiIsInR5cGUiOiJNYW51YWxSZWZyZXNoU2VydmljZTIwMTgifX0sImp0aSI6Imh0dHA6Ly9leGFtcGxlLmVkdS9jcmVkZW50aWFscy8zNzMyIn0"

        let signed = header + "." + claims
        let signatureString = "f_T5i5UDBB09wNrY3kCMoYbm4FyRn6AiOmN-WwZoFwFzapyhzj03R-imHJO9MuZRXawKdckqR5sIxTwkKZyyDw"

        let x = Data(fromBase64URL: "wq2NoIUbjjw7B5SO_MjaM7A8TDvmvmJE9B7tSd0Vhb0")!
        let y = Data(fromBase64URL: "_KDYcLiEeGfyQOt5INTZtH9Ocu4ZyKbZuEXPAsrEWOs")!
        let headerKey: UInt8 = 0x04
        let keyData = [headerKey] + x + y
        let pubKey = try secp256k1.Signing.PublicKey(rawRepresentation: keyData, format: .uncompressed)

        print(pubKey.rawRepresentation.base64EncodedString())

        let signature = try secp256k1.Signing.ECDSASignature(compactRepresentation: signatureString.data(using: .utf8)!)

        print(try signature.derRepresentation.base64Encoded())

        XCTAssertTrue(
            pubKey
                .ecdsa
                .isValidSignature(
                    signature,
                    for: signed.data(using: .utf8)!
        ))
    }
}
