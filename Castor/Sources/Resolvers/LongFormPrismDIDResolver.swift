import Core
import Domain
import Foundation

struct LongFormPrismDIDResolver: DIDResolver {
    let apollo: Apollo

    func resolve(did: DID) throws -> DIDDocument {
        let prismDID = try LongFormPrismDID(did: did)
        guard
            let data = Base64Utils().decodeMethodID(str: prismDID.encodedState)
        else { throw CastorError.initialStateOfDIDChanged }

        let (verificationMethods, services) = try decodeState(
            did: did,
            stateHash: prismDID.stateHash,
            encodedData: data
        )

        let authenticate = verificationMethods.first.map {
            DIDDocument.Authentication(urls: [$0.key], verificationMethods: [])
        }

        let servicesProperty = DIDDocument.Services(values: services)

        let verificationMethodsProperty = DIDDocument.VerificationMethods(values: Array(verificationMethods.values))

        let properties = [
            authenticate,
            servicesProperty,
            verificationMethodsProperty
        ].compactMap { $0 as? DIDDocumentCoreProperty }

        return DIDDocument(
            id: did,
            coreProperties: properties
        )
    }

    private func decodeState(
        did: DID,
        stateHash: String,
        encodedData: Data
    ) throws -> ([String: DIDDocument.VerificationMethod], [DIDDocument.Service]) {
        guard stateHash == encodedData.sha256() else { throw CastorError.initialStateOfDIDChanged }
        let operation = try Io_Iohk_Atala_Prism_Protos_AtalaOperation(serializedData: encodedData)
        let publicKeys = try operation.createDid.didData.publicKeys.map {
            try PrismDIDPublicKey(apollo: apollo, proto: $0)
        }
        let services = operation.createDid.didData.services.map {
            DIDDocument.Service(
                id: $0.id,
                type: $0.types,
                serviceEndpoint: .init(uri: $0.serviceEndpoint)
            )
        }
        return (publicKeys.reduce(
            [String: DIDDocument.VerificationMethod]())
        { partialResult, publicKey in
            let didUrl = DIDUrl(
                did: did,
                fragment: publicKey.id
            )

            let method = DIDDocument.VerificationMethod(
                id: didUrl,
                controller: did,
                type: publicKey.keyData.curve,
                publicKeyMultibase: publicKey.keyData.value.base64EncodedString()
            )
            var result = partialResult
            result[didUrl.string] = method
            return result
        }, services)
    }
}
