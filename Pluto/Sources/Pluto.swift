public struct PlutoImpl {
    public struct PlutoSetup {
        public struct KeychainSetup {
            public let service: String
            public let accessGroup: String?

            public init(
                service: String = "com.atala.prism.session",
                accessGroup: String? = nil
            ) {
                self.service = service
                self.accessGroup = accessGroup
            }
        }

        public let keychainSetup: KeychainSetup
        public let coreDataSetup: CoreDataManager.CoreDataSetup

        public init(
            keychainSetup: KeychainSetup,
            coreDataSetup: CoreDataManager.CoreDataSetup = .init(
                modelPath: .storeName("com.atala.prism.storage"),
                storeType: .persistent
            )
        ) {
            self.keychainSetup = keychainSetup
            self.coreDataSetup = coreDataSetup
        }
    }

    let setup: PlutoSetup

    public init(setup: PlutoSetup = .init(keychainSetup: .init())) {
        self.setup = setup
    }
}
