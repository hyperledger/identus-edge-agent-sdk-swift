import Core
import Domain
import Foundation

struct CreatePrismDIDOperation {
    private let method: DIDMethod = "prism"
    let apollo: Apollo
    let masterPublicKey: PublicKey
    let services: [DIDDocument.Service]

    func compute() throws -> DID {
        var operation = Io_Iohk_Atala_Prism_Protos_AtalaOperation()
        operation.createDid = createDIDAtalaOperation(
            publicKeys: [PrismDIDPublicKey(
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
    ) -> Io_Iohk_Atala_Prism_Protos_CreateDIDOperation {
        var didData = Io_Iohk_Atala_Prism_Protos_CreateDIDOperation.DIDCreationData()
        didData.publicKeys = publicKeys.map { $0.toProto() }
        didData.services = services.map {
            var service = Io_Iohk_Atala_Prism_Protos_CreateDIDOperation.DIDService()
            service.id = $0.id
            service.types = $0.type
            service.serviceEndpoint = $0.service
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
        let methodSpecificId = try PrismDIDMethodId(
            sections: [
                stateHash,
                Base64Utils().encodeMethodID(data: encodedState)
            ]
        )
        return DID(method: method, methodId: methodSpecificId.description)
    }
}
