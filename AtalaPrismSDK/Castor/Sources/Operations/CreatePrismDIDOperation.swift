import Core
import Domain
import Foundation

struct CreatePrismDIDOperation {
    private let method: DIDMethod = "prism"
    let apollo: Apollo
    let masterPublicKey: PublicKeyD
    let services: [DIDDocument.Service]

    func compute() throws -> DID {
        var operation = Io_Iohk_Atala_Prism_Protos_AtalaOperation()
        operation.createDid = try createDIDAtalaOperation(
            publicKeys: [PrismDIDPublicKey(
                apollo: apollo,
                id: PrismDIDPublicKey.Usage.authenticationKey.defaultId,
                usage: .authenticationKey,
                keyData: masterPublicKey
            ),
            PrismDIDPublicKey(
                apollo: apollo,
                id: PrismDIDPublicKey.Usage.masterKey.defaultId,
                usage: .masterKey,
                keyData: masterPublicKey
            )],
            services: services
        )
        return try createLongFormFromOperation(method: method, atalaOperation: operation)
    }

    private func createDIDAtalaOperation(
        publicKeys: [PrismDIDPublicKey],
        services: [DIDDocument.Service]
    ) throws -> Io_Iohk_Atala_Prism_Protos_CreateDIDOperation {
        var didData = Io_Iohk_Atala_Prism_Protos_CreateDIDOperation.DIDCreationData()
        didData.publicKeys = try publicKeys.map { try $0.toProto() }
        didData.services = services.map {
            var service = Io_Iohk_Atala_Prism_Protos_Service()
            service.id = $0.id
            service.type = $0.type.first ?? ""
            service.serviceEndpoint = $0.serviceEndpoint.map { $0.uri }
            return service
        }

        var operation = Io_Iohk_Atala_Prism_Protos_CreateDIDOperation()
        operation.didData = didData
        return operation
    }

    private func createLongFormFromOperation(
        method: DIDMethod,
        atalaOperation: Io_Iohk_Atala_Prism_Protos_AtalaOperation
    ) throws -> DID {
        let encodedState = try atalaOperation.serializedData()
        let stateHash = encodedState.sha256()
        let base64State = encodedState.base64UrlEncodedString()
        let methodSpecificId = try PrismDIDMethodId(
            sections: [
                stateHash,
                base64State
            ]
        )
        return DID(method: method, methodId: methodSpecificId.description)
    }
}
