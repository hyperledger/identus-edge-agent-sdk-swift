import Domain

public struct PlutoImpl {
    public struct PlutoSetup {
        public let coreDataSetup: CoreDataManager.CoreDataSetup

        public init(
            coreDataSetup: CoreDataManager.CoreDataSetup = .init(
                modelPath: .storeName("PrismPluto"),
                storeType: .persistent
            )
        ) {
            self.coreDataSetup = coreDataSetup
        }
    }

    let setup: PlutoSetup
    let registeredDIDDao: CDRegisteredDIDDAO
    let privateKeyDIDDao: CDDIDPrivateKeyDAO
    let pairDIDDao: CDDIDPairDAO
    let messageDao: CDMessageDAO
    let mediatorDAO: CDMediatorDIDDAO
    let credentialsDAO: CDCredentialDAO
    let linkSecretDao: CDLinkSecretDAO
    private let coreDataManager: CoreDataManager
    private let keyRestoration: KeyRestoration

    public init(setup: PlutoSetup = .init(), keyRestoration: KeyRestoration) {
        let manager = CoreDataManager(setup: setup.coreDataSetup)
        self.keyRestoration = keyRestoration
        self.setup = setup
        self.coreDataManager = manager
        self.registeredDIDDao = CDRegisteredDIDDAO(
            readContext: manager.mainContext,
            writeContext: manager.editContext
        )
        let privateKeyDao = CDDIDPrivateKeyDAO(
            keyRestoration: keyRestoration,
            readContext: manager.mainContext,
            writeContext: manager.editContext
        )
        let pairDIDDao = CDDIDPairDAO(
            readContext: manager.mainContext,
            writeContext: manager.editContext,
            privateKeyDIDDAO: privateKeyDao
        )
        let messageDao = CDMessageDAO(
            readContext: manager.mainContext,
            writeContext: manager.editContext,
            pairDAO: pairDIDDao
        )
        self.privateKeyDIDDao = privateKeyDao
        self.pairDIDDao = pairDIDDao
        self.messageDao = messageDao
        self.mediatorDAO = CDMediatorDIDDAO(
            readContext: manager.mainContext,
            writeContext: manager.editContext,
            didDAO: CDDIDDAO(
                readContext: manager.mainContext,
                writeContext: manager.editContext
            ),
            privateKeyDIDDao: privateKeyDao
        )
        self.credentialsDAO = CDCredentialDAO(
            readContext: manager.mainContext,
            writeContext: manager.editContext
        )
        self.linkSecretDao = CDLinkSecretDAO(
            readContext: manager.mainContext,
            writeContext: manager.editContext
        )
    }
}
