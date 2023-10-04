import Domain

public struct PlutoImpl {
    public struct PlutoSetup {
        public let coreDataSetup: CoreDataManager.CoreDataSetup
        public let keychainService: String
        public let keychain: KeychainStore & KeychainProvider
        
        public init(
            coreDataSetup: CoreDataManager.CoreDataSetup = .init(
                modelPath: .storeName("PrismPluto"),
                storeType: .persistent
            ),
            keychainService: String = "atala.prism.service",
            keychainAccessGroup: String? = nil
        ) {
            self.init(
                coreDataSetup: coreDataSetup,
                keychainService: keychainService,
                keychain: KeychainDAO(accessGroup: keychainAccessGroup)
            )
        }
        
        public init(
            coreDataSetup: CoreDataManager.CoreDataSetup = .init(
                modelPath: .storeName("PrismPluto"),
                storeType: .persistent
            ),
            keychainService: String = "atala.prism.service",
            keychain: (KeychainStore & KeychainProvider)
        ) {
            self.coreDataSetup = coreDataSetup
            self.keychainService = keychainService
            self.keychain = keychain
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

    public init(setup: PlutoSetup = .init()) {
        let manager = CoreDataManager(setup: setup.coreDataSetup)
        self.setup = setup
        self.coreDataManager = manager
        self.registeredDIDDao = CDRegisteredDIDDAO(
            readContext: manager.mainContext,
            writeContext: manager.editContext
        )
        let privateKeyDao = CDDIDPrivateKeyDAO(
            keychain: setup.keychain,
            keychainService: setup.keychainService,
            keyDao: CDKeyDAO(
                readContext: manager.mainContext,
                writeContext: manager.editContext
            ),
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
