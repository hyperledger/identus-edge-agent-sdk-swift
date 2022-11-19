import Domain

public struct PlutoImpl {
    public struct PlutoSetup {
        public let coreDataSetup: CoreDataManager.CoreDataSetup

        public init(
            coreDataSetup: CoreDataManager.CoreDataSetup = .init(
                modelPath: .storeName("com.atala.prism.storage"),
                storeType: .persistent
            )
        ) {
            self.coreDataSetup = coreDataSetup
        }
    }

    let setup: PlutoSetup
    let registeredDIDDao: CDRegisteredDIDDAO
    private let coreDataManager: CoreDataManager

    public init(setup: PlutoSetup = .init()) {
        let manager = CoreDataManager(setup: setup.coreDataSetup)
        self.setup = setup
        self.coreDataManager = manager
        self.registeredDIDDao = CDRegisteredDIDDAO(
            readContext: manager.mainContext,
            writeContext: manager.editContext
        )
    }
}
