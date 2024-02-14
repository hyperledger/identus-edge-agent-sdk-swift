import Apollo
import Castor
import Domain
import CryptoKit
import PrismAgent
@testable import Pollux
import XCTest
import secp256k1

final class JWTTests: XCTestCase {

    lazy var apollo = ApolloImpl()
    lazy var castor = CastorImpl(apollo: apollo)
    
    func testParseJWTCredential() throws {
        let validJWTString = "eyJhbGciOiJFUzI1NksifQ.eyJpc3MiOiJkaWQ6cHJpc206MmU0MGZkNjkyYjgzYzE5ZjlhNTUzNjRjMmNhNWJmNjkyOGI4ODU1NGE1YmYxMTc0YTc4ZjY4NDk4ZDgwZGZjNjpDcmNCQ3JRQkVqa0tCV3RsZVMweEVBSktMZ29KYzJWamNESTFObXN4RWlFQ1pDbDV4aUREb3ZsVFlNNVVSeXdHODZPWjc2RWNTY3NjSEplaHRnbWNKTlFTT2dvR1lYVjBhQzB4RUFSS0xnb0pjMlZqY0RJMU5tc3hFaUVDRUMzTUNPak4xb1lNZjU2ZVVBaTA3NkxGX2hRZDRwbFFib3JKcnBkOHdHY1NPd29IYldGemRHVnlNQkFCU2k0S0NYTmxZM0F5TlRack1SSWhBeTVqVkc4UTRWOHRYV0RoUWNvb2xPTmFIdTZHaW5ockJ6SEtfRXYySW9yNSIsInN1YiI6ImRpZDpwcmlzbTo4ODYwN2Y4YjE3ZWJhZmNhODgwNDdmZDQ0YTMyZTE4NGI1MGYwM2QyNWZhZWQ1ZGRiYWQyZGRjNGYyZjg5YWYzOkNzY0JDc1FCRW1RS0QyRjFkR2hsYm5ScFkyRjBhVzl1TUJBRVFrOEtDWE5sWTNBeU5UWnJNUklncnFDMVhaN2ZsOUpLSjBNT3pTa2hSZFhESHpnSVQzTGJ1MlNLdTJvZWxKVWFJT3gxSzFvY2NDRG14SS05Zm9jRm84emhpTm5BYXBPUGFXQXY0UGg0azZjWkVsd0tCMjFoYzNSbGNqQVFBVUpQQ2dselpXTndNalUyYXpFU0lLNmd0VjJlMzVmU1NpZEREczBwSVVYVnd4ODRDRTl5Mjd0a2lydHFIcFNWR2lEc2RTdGFISEFnNXNTUHZYNkhCYVBNNFlqWndHcVRqMmxnTC1ENGVKT25HUSIsIm5iZiI6MTY4ODA1ODcyNywiZXhwIjoxNjg4MDYyMzI3LCJ2YyI6eyJjcmVkZW50aWFsU2NoZW1hIjp7ImlkIjoiaHR0cHM6XC9cL2s4cy1kZXYuYXRhbGFwcmlzbS5pb1wvcHJpc20tYWdlbnRcL3NjaGVtYS1yZWdpc3RyeVwvc2NoZW1hc1wvMDIwMTY5M2ItNGQ2ZC0zNmVjLWEzN2QtODFkODhlODcyNTM5IiwidHlwZSI6IkNyZWRlbnRpYWxTY2hlbWEyMDIyIn0sImNyZWRlbnRpYWxTdWJqZWN0Ijp7InRlc3QiOiJUZXN0MSIsImlkIjoiZGlkOnByaXNtOjg4NjA3ZjhiMTdlYmFmY2E4ODA0N2ZkNDRhMzJlMTg0YjUwZjAzZDI1ZmFlZDVkZGJhZDJkZGM0ZjJmODlhZjM6Q3NjQkNzUUJFbVFLRDJGMWRHaGxiblJwWTJGMGFXOXVNQkFFUWs4S0NYTmxZM0F5TlRack1SSWdycUMxWFo3Zmw5SktKME1PelNraFJkWERIemdJVDNMYnUyU0t1Mm9lbEpVYUlPeDFLMW9jY0NEbXhJLTlmb2NGbzh6aGlObkFhcE9QYVdBdjRQaDRrNmNaRWx3S0IyMWhjM1JsY2pBUUFVSlBDZ2x6WldOd01qVTJhekVTSUs2Z3RWMmUzNWZTU2lkRERzMHBJVVhWd3g4NENFOXkyN3RraXJ0cUhwU1ZHaURzZFN0YUhIQWc1c1NQdlg2SEJhUE00WWpad0dxVGoybGdMLUQ0ZUpPbkdRIn0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiXSwiQGNvbnRleHQiOlsiaHR0cHM6XC9cL3d3dy53My5vcmdcLzIwMThcL2NyZWRlbnRpYWxzXC92MSJdfX0.JZBqArVFvWgj2W0b7vVPSKR3mSH_X-VOC-YQ_jyLZSOEYUkortkRGi41xwA7SPFSqPdSCHl4iagpBir1tYMBOw"
        
        let jwtData = validJWTString.data(using: .utf8)!
        let credential = try JWTCredential(data: jwtData)
        XCTAssertEqual(credential.claims.map(\.key).sorted(), ["id", "test"].sorted())
        XCTAssertEqual(credential.id, validJWTString)
    }
    
//    func testJWTCreateCredentialRequest() async throws {
//        let offerCredentialMessage =  OfferCredential3_0(
//            id: "test1",
//            body: .init(
//                goalCode: nil,
//                comment: nil,
//                replacementId: nil,
//                multipleAvailable: nil,
//                credentialPreview: .init(schemaId: "", attributes: [])
//            ),
//            type: "test",
//            attachments: [.init(
//                id: "",
//                mediaType: nil,
//                data: AttachmentJsonData(data: "{\"domain\":\"test\", \"challenge\":\"test\"}".data(using: .utf8)!),
//                filename: nil,
//                format: nil,
//                lastmodTime: nil,
//                byteCount: nil,
//                description: nil
//            )],
//            thid: nil,
//            from: DID.init(method: "test", methodId: "123"),
//            to: DID.init(method: "test", methodId: "123")
//        )
//        
//        let pollux = PolluxImpl()
//        let privKey = try apollo.createPrivateKey(parameters: [
//            KeyProperties.type.rawValue: "EC",
//            KeyProperties.derivationPath.rawValue: DerivationPath(index: 0).keyPathString(),
//            KeyProperties.curve.rawValue: KnownKeyCurves.secp256k1.rawValue,
//            KeyProperties.rawKey.rawValue: Data(fromBase64URL: "N_JFgvYaReyRXwassz5FHg33A4I6dczzdXrjdHGksmg")!.base64Encoded()
//        ]) as! PrivateKey & ExportableKey
//
//        let pubKey = privKey.publicKey()
//        let subjectPrismDID = try castor.createPrismDID(masterPublicKey: pubKey, services: [])
//        
//        let requestString = try await pollux.processCredentialRequest(
//            offerMessage: offerCredentialMessage.makeMessage(),
//            options: [
//                .subjectDID(subjectPrismDID),
//                .exportableKey(privKey)
//            ]
//        )
//        
//        let validJWTString = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJub25jZSI6InRlc3QiLCJpc3MiOiJkaWQ6cHJpc206OTRiY2RkZGIxN2E2NTY1NTg2NGYxZGEzYjIyNzU2NTI1NmJjZTM2MTg1Y2EwMzE5OWVlZjNiNmNkMTg4MTBlZDpDc2NCQ3NRQkVtUUtEMkYxZEdobGJuUnBZMkYwYVc5dU1CQUVRazhLQ1hObFkzQXlOVFpyTVJJZ1A2WGlXdERvYWo2ZzNsZTEybGpxamwzSl9aWGFfa1Jzd0M5R05VWW1rVFVhSUlHRlZFU1g4U2pLVFQ1eXBTNi1ERGl6VldtTHdUVHFNdlMtZEJQSTFjZkVFbHdLQjIxaGMzUmxjakFRQVVKUENnbHpaV053TWpVMmF6RVNJRC1sNGxyUTZHby1vTjVYdGRwWTZvNWR5ZjJWMnY1RWJNQXZSalZHSnBFMUdpQ0JoVlJFbF9Fb3lrMC1jcVV1dmd3NHMxVnBpOEUwNmpMMHZuUVR5TlhIeEEiLCJ2cCI6eyJAY29udGV4dCI6WyJodHRwczpcL1wvd3d3LnczLm9yZ1wvMjAxOFwvcHJlc2VudGF0aW9uc1wvdjEiXSwidHlwZSI6WyJWZXJpZmlhYmxlUHJlc2VudGF0aW9uIl19LCJhdWQiOiJ0ZXN0In0.gBfP9y5dscgc--DoKWQ8eWGjJ8yRsfwbDH1sHwMIgm5cSUpvGnzpn4wsrLIsCMG6Udp2H2N-jaFnXhjeE28-lA"
//        
//        let verifier = JWT<ClaimsRequestSignatureJWT>.verify(requestString, using: .es256k(publicKey: pubKey.exporting!.pem.data(using: .utf8)!))
//        XCTAssertTrue(verifier)
//        XCTAssertEqual(validJWTString, requestString)
//    }
//    
//    func testJWTCreateCredentialRequestErrorMissingDomain() async throws {
//        let offerCredentialMessage = OfferCredential(
//            id: "test1",
//            body: .init(
//                credentialPreview: CredentialPreview(attributes: []),
//                formats: []
//            ),
//            type: "test",
//            attachments: [.init(
//                id: "",
//                mediaType: nil,
//                data: AttachmentJsonData(data: "{\"challenge\":\"test\"}".data(using: .utf8)!),
//                filename: nil,
//                format: nil,
//                lastmodTime: nil,
//                byteCount: nil,
//                description: nil
//            )],
//            thid: nil,
//            from: DID.init(method: "test", methodId: "123"),
//            to: DID.init(method: "test", methodId: "123")
//        )
//        
//        let pollux = PolluxImpl()
//        let privKey = try apollo.createPrivateKey(parameters: [
//            KeyProperties.type.rawValue: "EC",
//            KeyProperties.curve.rawValue: KnownKeyCurves.secp256k1.rawValue,
//            KeyProperties.rawKey.rawValue: Data(fromBase64URL: "N_JFgvYaReyRXwassz5FHg33A4I6dczzdXrjdHGksmg")!.base64Encoded()
//        ]) as! PrivateKey & ExportableKey
//
//        let pubKey = privKey.publicKey()
//        let subjectPrismDID = try castor.createPrismDID(masterPublicKey: pubKey, services: [])
//        do {
//            try await pollux.processCredentialRequest(
//                offerMessage: offerCredentialMessage.makeMessage(),
//                options: [
//                    .subjectDID(subjectPrismDID),
//                    .exportableKey(privKey)
//                ]
//            )
//            XCTFail("Should throw an error")
//        } catch {
//            
//        }
//    }
//    
//    func testJWTPresentationSignature() async throws {
//        let requestPresentation = RequestPresentation(
//            body: .init(proofTypes: []),
//            attachments: [.init(
//                id: "",
//                mediaType: nil,
//                data: AttachmentJsonData(data: "{\"domain\":\"test\", \"challenge\":\"test\"}".data(using: .utf8)!),
//                filename: nil,
//                format: nil,
//                lastmodTime: nil,
//                byteCount: nil,
//                description: nil
//            )],
//            thid: nil,
//            from: DID.init(method: "test", methodId: "123"),
//            to: DID.init(method: "test", methodId: "123")
//        )
//        
//        let cred = createJWTCredential()
//        let privKey = try apollo.createPrivateKey(parameters: [
//            KeyProperties.type.rawValue: "EC",
//            KeyProperties.curve.rawValue: KnownKeyCurves.secp256k1.rawValue,
//            KeyProperties.rawKey.rawValue: Data(fromBase64URL: "N_JFgvYaReyRXwassz5FHg33A4I6dczzdXrjdHGksmg")!.base64Encoded()
//        ]) as! PrivateKey & ExportableKey
//
//        let pubKey = privKey.publicKey()
//        let subjectPrismDID = try castor.createPrismDID(masterPublicKey: pubKey, services: [])
//        let resultString = try cred.proof?.presentation(
//            request: requestPresentation.makeMessage(),
//            options: [
//                .subjectDID(subjectPrismDID),
//                .exportableKey(privKey)
//            ]
//        )
//        
//        let validResultString = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJub25jZSI6InRlc3QiLCJpc3MiOiJkaWQ6cHJpc206OTRiY2RkZGIxN2E2NTY1NTg2NGYxZGEzYjIyNzU2NTI1NmJjZTM2MTg1Y2EwMzE5OWVlZjNiNmNkMTg4MTBlZDpDc2NCQ3NRQkVtUUtEMkYxZEdobGJuUnBZMkYwYVc5dU1CQUVRazhLQ1hObFkzQXlOVFpyTVJJZ1A2WGlXdERvYWo2ZzNsZTEybGpxamwzSl9aWGFfa1Jzd0M5R05VWW1rVFVhSUlHRlZFU1g4U2pLVFQ1eXBTNi1ERGl6VldtTHdUVHFNdlMtZEJQSTFjZkVFbHdLQjIxaGMzUmxjakFRQVVKUENnbHpaV053TWpVMmF6RVNJRC1sNGxyUTZHby1vTjVYdGRwWTZvNWR5ZjJWMnY1RWJNQXZSalZHSnBFMUdpQ0JoVlJFbF9Fb3lrMC1jcVV1dmd3NHMxVnBpOEUwNmpMMHZuUVR5TlhIeEEiLCJ2cCI6eyJAY29udGV4dCI6WyJodHRwczpcL1wvd3d3LnczLm9yZ1wvMjAxOFwvcHJlc2VudGF0aW9uc1wvdjEiXSwidHlwZSI6WyJWZXJpZmlhYmxlUHJlc2VudGF0aW9uIl0sInZlcmlmaWFibGVDcmVkZW50aWFsIjpbImV5SmhiR2NpT2lKRlV6STFOa3NpZlEuZXlKcGMzTWlPaUprYVdRNmNISnBjMjA2TW1VME1HWmtOamt5WWpnell6RTVaamxoTlRVek5qUmpNbU5oTldKbU5qa3lPR0k0T0RVMU5HRTFZbVl4TVRjMFlUYzRaalk0TkRrNFpEZ3daR1pqTmpwRGNtTkNRM0pSUWtWcWEwdENWM1JzWlZNd2VFVkJTa3RNWjI5S1l6SldhbU5FU1RGT2JYTjRSV2xGUTFwRGJEVjRhVVJFYjNac1ZGbE5OVlZTZVhkSE9EWlBXamMyUldOVFkzTmpTRXBsYUhSbmJXTktUbEZUVDJkdlIxbFlWakJoUXpCNFJVRlNTMHhuYjBwak1sWnFZMFJKTVU1dGMzaEZhVVZEUlVNelRVTlBhazR4YjFsTlpqVTJaVlZCYVRBM05reEdYMmhSWkRSd2JGRmliM0pLY25Ca09IZEhZMU5QZDI5SVlsZEdlbVJIVm5sTlFrRkNVMmswUzBOWVRteFpNMEY1VGxSYWNrMVNTV2hCZVRWcVZrYzRVVFJXT0hSWVYwUm9VV052YjJ4UFRtRklkVFpIYVc1b2NrSjZTRXRmUlhZeVNXOXlOU0lzSW5OMVlpSTZJbVJwWkRwd2NtbHpiVG80T0RZd04yWTRZakUzWldKaFptTmhPRGd3TkRkbVpEUTBZVE15WlRFNE5HSTFNR1l3TTJReU5XWmhaV1ExWkdSaVlXUXlaR1JqTkdZeVpqZzVZV1l6T2tOelkwSkRjMUZDUlcxUlMwUXlSakZrUjJoc1ltNVNjRmt5UmpCaFZ6bDFUVUpCUlZGck9FdERXRTVzV1ROQmVVNVVXbkpOVWtsbmNuRkRNVmhhTjJac09VcExTakJOVDNwVGEyaFNaRmhFU0hwblNWUXpUR0oxTWxOTGRUSnZaV3hLVldGSlQzZ3hTekZ2WTJORFJHMTRTUzA1Wm05alJtODRlbWhwVG01QllYQlBVR0ZYUVhZMFVHZzBhelpqV2tWc2QwdENNakZvWXpOU2JHTnFRVkZCVlVwUVEyZHNlbHBYVG5kTmFsVXlZWHBGVTBsTE5tZDBWakpsTXpWbVUxTnBaRVJFY3pCd1NWVllWbmQ0T0RSRFJUbDVNamQwYTJseWRIRkljRk5XUjJsRWMyUlRkR0ZJU0VGbk5YTlRVSFpZTmtoQ1lWQk5ORmxxV25kSGNWUnFNbXhuVEMxRU5HVktUMjVIVVNJc0ltNWlaaUk2TVRZNE9EQTFPRGN5Tnl3aVpYaHdJam94TmpnNE1EWXlNekkzTENKMll5STZleUpqY21Wa1pXNTBhV0ZzVTJOb1pXMWhJanA3SW1sa0lqb2lhSFIwY0hNNlhDOWNMMnM0Y3kxa1pYWXVZWFJoYkdGd2NtbHpiUzVwYjF3dmNISnBjMjB0WVdkbGJuUmNMM05qYUdWdFlTMXlaV2RwYzNSeWVWd3ZjMk5vWlcxaGMxd3ZNREl3TVRZNU0ySXROR1EyWkMwek5tVmpMV0V6TjJRdE9ERmtPRGhsT0RjeU5UTTVJaXdpZEhsd1pTSTZJa055WldSbGJuUnBZV3hUWTJobGJXRXlNREl5SW4wc0ltTnlaV1JsYm5ScFlXeFRkV0pxWldOMElqcDdJblJsYzNRaU9pSlVaWE4wTVNJc0ltbGtJam9pWkdsa09uQnlhWE50T2pnNE5qQTNaamhpTVRkbFltRm1ZMkU0T0RBME4yWmtORFJoTXpKbE1UZzBZalV3WmpBelpESTFabUZsWkRWa1pHSmhaREprWkdNMFpqSm1PRGxoWmpNNlEzTmpRa056VVVKRmJWRkxSREpHTVdSSGFHeGlibEp3V1RKR01HRlhPWFZOUWtGRlVXczRTME5ZVG14Wk0wRjVUbFJhY2sxU1NXZHljVU14V0ZvM1ptdzVTa3RLTUUxUGVsTnJhRkprV0VSSWVtZEpWRE5NWW5VeVUwdDFNbTlsYkVwVllVbFBlREZMTVc5alkwTkViWGhKTFRsbWIyTkdiemg2YUdsT2JrRmhjRTlRWVZkQmRqUlFhRFJyTm1OYVJXeDNTMEl5TVdoak0xSnNZMnBCVVVGVlNsQkRaMng2V2xkT2QwMXFWVEpoZWtWVFNVczJaM1JXTW1Vek5XWlRVMmxrUkVSek1IQkpWVmhXZDNnNE5FTkZPWGt5TjNScmFYSjBjVWh3VTFaSGFVUnpaRk4wWVVoSVFXYzFjMU5RZGxnMlNFSmhVRTAwV1dwYWQwZHhWR295YkdkTUxVUTBaVXBQYmtkUkluMHNJblI1Y0dVaU9sc2lWbVZ5YVdacFlXSnNaVU55WldSbGJuUnBZV3dpWFN3aVFHTnZiblJsZUhRaU9sc2lhSFIwY0hNNlhDOWNMM2QzZHk1M015NXZjbWRjTHpJd01UaGNMMk55WldSbGJuUnBZV3h6WEM5Mk1TSmRmWDAuSlpCcUFyVkZ2V2dqMlcwYjd2VlBTS1IzbVNIX1gtVk9DLVlRX2p5TFpTT0VZVWtvcnRrUkdpNDF4d0E3U1BGU3FQZFNDSGw0aWFncEJpcjF0WU1CT3ciXX0sImF1ZCI6InRlc3QifQ.vEUJnRmJsp7H7IKgQfDBSn12HPBXXVyEySI8sXHtwPRFTGOCvOpB6PImrn7N4I4ENmV6vLadJf5ZbO2n9hBwDw"
//        
//        XCTAssertEqual(validResultString, resultString)
//    }
//    
//    private func createJWTCredential() -> Credential {
//        let jwtString = "eyJhbGciOiJFUzI1NksifQ.eyJpc3MiOiJkaWQ6cHJpc206MmU0MGZkNjkyYjgzYzE5ZjlhNTUzNjRjMmNhNWJmNjkyOGI4ODU1NGE1YmYxMTc0YTc4ZjY4NDk4ZDgwZGZjNjpDcmNCQ3JRQkVqa0tCV3RsZVMweEVBSktMZ29KYzJWamNESTFObXN4RWlFQ1pDbDV4aUREb3ZsVFlNNVVSeXdHODZPWjc2RWNTY3NjSEplaHRnbWNKTlFTT2dvR1lYVjBhQzB4RUFSS0xnb0pjMlZqY0RJMU5tc3hFaUVDRUMzTUNPak4xb1lNZjU2ZVVBaTA3NkxGX2hRZDRwbFFib3JKcnBkOHdHY1NPd29IYldGemRHVnlNQkFCU2k0S0NYTmxZM0F5TlRack1SSWhBeTVqVkc4UTRWOHRYV0RoUWNvb2xPTmFIdTZHaW5ockJ6SEtfRXYySW9yNSIsInN1YiI6ImRpZDpwcmlzbTo4ODYwN2Y4YjE3ZWJhZmNhODgwNDdmZDQ0YTMyZTE4NGI1MGYwM2QyNWZhZWQ1ZGRiYWQyZGRjNGYyZjg5YWYzOkNzY0JDc1FCRW1RS0QyRjFkR2hsYm5ScFkyRjBhVzl1TUJBRVFrOEtDWE5sWTNBeU5UWnJNUklncnFDMVhaN2ZsOUpLSjBNT3pTa2hSZFhESHpnSVQzTGJ1MlNLdTJvZWxKVWFJT3gxSzFvY2NDRG14SS05Zm9jRm84emhpTm5BYXBPUGFXQXY0UGg0azZjWkVsd0tCMjFoYzNSbGNqQVFBVUpQQ2dselpXTndNalUyYXpFU0lLNmd0VjJlMzVmU1NpZEREczBwSVVYVnd4ODRDRTl5Mjd0a2lydHFIcFNWR2lEc2RTdGFISEFnNXNTUHZYNkhCYVBNNFlqWndHcVRqMmxnTC1ENGVKT25HUSIsIm5iZiI6MTY4ODA1ODcyNywiZXhwIjoxNjg4MDYyMzI3LCJ2YyI6eyJjcmVkZW50aWFsU2NoZW1hIjp7ImlkIjoiaHR0cHM6XC9cL2s4cy1kZXYuYXRhbGFwcmlzbS5pb1wvcHJpc20tYWdlbnRcL3NjaGVtYS1yZWdpc3RyeVwvc2NoZW1hc1wvMDIwMTY5M2ItNGQ2ZC0zNmVjLWEzN2QtODFkODhlODcyNTM5IiwidHlwZSI6IkNyZWRlbnRpYWxTY2hlbWEyMDIyIn0sImNyZWRlbnRpYWxTdWJqZWN0Ijp7InRlc3QiOiJUZXN0MSIsImlkIjoiZGlkOnByaXNtOjg4NjA3ZjhiMTdlYmFmY2E4ODA0N2ZkNDRhMzJlMTg0YjUwZjAzZDI1ZmFlZDVkZGJhZDJkZGM0ZjJmODlhZjM6Q3NjQkNzUUJFbVFLRDJGMWRHaGxiblJwWTJGMGFXOXVNQkFFUWs4S0NYTmxZM0F5TlRack1SSWdycUMxWFo3Zmw5SktKME1PelNraFJkWERIemdJVDNMYnUyU0t1Mm9lbEpVYUlPeDFLMW9jY0NEbXhJLTlmb2NGbzh6aGlObkFhcE9QYVdBdjRQaDRrNmNaRWx3S0IyMWhjM1JsY2pBUUFVSlBDZ2x6WldOd01qVTJhekVTSUs2Z3RWMmUzNWZTU2lkRERzMHBJVVhWd3g4NENFOXkyN3RraXJ0cUhwU1ZHaURzZFN0YUhIQWc1c1NQdlg2SEJhUE00WWpad0dxVGoybGdMLUQ0ZUpPbkdRIn0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiXSwiQGNvbnRleHQiOlsiaHR0cHM6XC9cL3d3dy53My5vcmdcLzIwMThcL2NyZWRlbnRpYWxzXC92MSJdfX0.JZBqArVFvWgj2W0b7vVPSKR3mSH_X-VOC-YQ_jyLZSOEYUkortkRGi41xwA7SPFSqPdSCHl4iagpBir1tYMBOw"
//
//        return try! JWTCredential(data: jwtString.data(using: .utf8)!)
//    }
}
