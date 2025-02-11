import Domain
@testable import Pluto
import XCTest

final class CDDIDPrivateKeyDAOTestsTests: XCTestCase {
    private var coreDataManager: CoreDataManager!
    private var keychainMock: KeychainMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager(setup: .init(
            modelPath: .storeName("PrismPluto"),
            storeType: .memory
        ))

        keychainMock = KeychainMock()
    }

    func testStoreSingleDID() throws {
        let dao = CDDIDPrivateKeyDAO(
            keyDao: CDKeyDAO(
                keychain: keychainMock,
                keychainService: "test",
                readContext: coreDataManager.mainContext,
                writeContext: coreDataManager.editContext
            ),
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID = DID(method: "test", methodId: "test")
        let testPrivateKey = MockPrivateKey(curve: .x25519)
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID,
            privateKeys: [testPrivateKey],
            alias: nil
        ).flatMap {
            dao.getDIDInfo(did: testDID)
        }.first().sink { _ in } receiveValue: {
            XCTAssertEqual(testDID, $0?.did)
            XCTAssertEqual([testPrivateKey.storableData], $0?.privateKeys.map { $0.storableData })
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testStoreNoDuplicatedDID() throws {
        let dao = CDDIDPrivateKeyDAO(
            keyDao: CDKeyDAO(
                keychain: keychainMock,
                keychainService: "test",
                readContext: coreDataManager.mainContext,
                writeContext: coreDataManager.editContext
            ),
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID = DID(method: "test", methodId: "test")
        let testPrivateKey = MockPrivateKey(curve: .ed25519)
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID,
            privateKeys: [testPrivateKey],
            alias: nil
        ).flatMap {
            dao.addDID(
                did: testDID,
                privateKeys: [testPrivateKey],
                alias: nil
            )
        }
        .flatMap {
            dao.getAll()
        }
        .first()
        .sink { _ in } receiveValue: {
            XCTAssertEqual($0.count, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testGetAllDIDs() throws {
        let dao = CDDIDPrivateKeyDAO(
            keyDao: CDKeyDAO(
                keychain: keychainMock,
                keychainService: "test",
                readContext: coreDataManager.mainContext,
                writeContext: coreDataManager.editContext
            ),
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID1 = DID(method: "test1", methodId: "test1")
        let testPrivateKey1 = MockPrivateKey(curve: .x25519)

        let testDID2 = DID(method: "test2", methodId: "test2")
        let testPrivateKey2 = MockPrivateKey(curve: .ed25519)

        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID1,
            privateKeys: [testPrivateKey1],
            alias: nil
        ).flatMap {
            dao.addDID(
                did: testDID2,
                privateKeys: [testPrivateKey2],
                alias: nil
            )
        }
        .flatMap {
            dao.getAll()
        }
        .first()
        .sink { _ in } receiveValue: {
            XCTAssertEqual($0.count, 2)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testGetDIDInfoByDID() throws {
        let dao = CDDIDPrivateKeyDAO(
            keyDao: CDKeyDAO(
                keychain: keychainMock,
                keychainService: "test",
                readContext: coreDataManager.mainContext,
                writeContext: coreDataManager.editContext
            ),
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID1 = DID(method: "test1", methodId: "test1")
        let testPrivateKey1 = MockPrivateKey(str: "Key1", curve: .x25519)

        let testDID2 = DID(method: "test2", methodId: "test2")
        let testPrivateKey2 = MockPrivateKey(str: "Key2", curve: .ed25519)

        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID1,
            privateKeys: [testPrivateKey1],
            alias: nil
        ).flatMap {
            dao.addDID(
                did: testDID2,
                privateKeys: [testPrivateKey2],
                alias: nil
            )
        }
        .flatMap {
            dao.getDIDInfo(did: testDID2)
        }
        .first()
        .sink { _ in } receiveValue: {
            XCTAssertEqual(testDID2, $0?.did)
            XCTAssertEqual([testPrivateKey2.storableData], $0?.privateKeys.map { $0.storableData })
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
