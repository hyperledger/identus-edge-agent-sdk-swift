import Domain
@testable import Pluto
import XCTest

final class CDDIDPrivateKeyDAOTestsTests: XCTestCase {
    private var coreDataManager: CoreDataManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager(setup: .init(
            modelPath: .storeName("PrismPluto"),
            storeType: .memory
        ))
    }

    func testStoreSingleDID() throws {
        let dao = CDDIDPrivateKeyDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID = DID(method: "test", methodId: "test")
        let testPrivateKey = PrivateKey(curve: .x25519, value: Data())
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID,
            privateKeys: [testPrivateKey]
        ).flatMap {
            dao.getDIDInfo(did: testDID)
        }.sink { _ in } receiveValue: {
            XCTAssertEqual(testDID, $0?.did)
            XCTAssertEqual([testPrivateKey], $0?.privateKeys)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testStoreNoDuplicatedDID() throws {
        let dao = CDDIDPrivateKeyDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID = DID(method: "test", methodId: "test")
        let testPrivateKey = PrivateKey(curve: .ed25519, value: Data())
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID,
            privateKeys: [testPrivateKey]
        ).flatMap {
            dao.addDID(
                did: testDID,
                privateKeys: [testPrivateKey]
            )
        }
        .flatMap {
            dao.getAll()
        }.sink { _ in } receiveValue: {
            XCTAssertEqual($0.count, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testGetAllDIDs() throws {
        let dao = CDDIDPrivateKeyDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID1 = DID(method: "test1", methodId: "test1")
        let testPrivateKey1 = PrivateKey(curve: .x25519, value: Data())

        let testDID2 = DID(method: "test2", methodId: "test2")
        let testPrivateKey2 = PrivateKey(curve: .ed25519, value: Data())

        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID1,
            privateKeys: [testPrivateKey1]
        ).flatMap {
            dao.addDID(
                did: testDID2,
                privateKeys: [testPrivateKey2]
            )
        }
        .flatMap {
            dao.getAll()
        }.sink { _ in } receiveValue: {
            XCTAssertEqual($0.count, 2)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testGetDIDInfoByDID() throws {
        let dao = CDDIDPrivateKeyDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID1 = DID(method: "test1", methodId: "test1")
        let testPrivateKey1 = PrivateKey(curve: .x25519, value: Data())

        let testDID2 = DID(method: "test2", methodId: "test2")
        let testPrivateKey2 = PrivateKey(curve: .ed25519, value: Data())

        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID1,
            privateKeys: [testPrivateKey1]
        ).flatMap {
            dao.addDID(
                did: testDID2,
                privateKeys: [testPrivateKey2]
            )
        }
        .flatMap {
            dao.getDIDInfo(did: testDID2)
        }.sink { _ in } receiveValue: {
            XCTAssertEqual(testDID2, $0?.did)
            XCTAssertEqual([testPrivateKey2], $0?.privateKeys)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}

extension PrivateKey: Equatable {
    public static func == (lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        lhs.curve == rhs.curve && lhs.value == rhs.value
    }
}
