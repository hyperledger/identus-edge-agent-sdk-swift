import Domain
@testable import Pluto
import XCTest

final class CDRegisteredDIDDaoTests: XCTestCase {
    private var coreDataManager: CoreDataManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager(setup: .init(
            modelPath: .storeName("PrismPluto", ModelKit.bundle),
            storeType: .memory
        ))
    }

    func testStoreSingleDID() throws {
        let dao = CDRegisteredDIDDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID = DID(method: "test", methodId: "test")
        let testKeyPairIndex = 0
        let testAlias = "Test"
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID,
            keyPairIndex: testKeyPairIndex,
            alias: testAlias
        ).flatMap {
            dao.getDIDInfo(did: testDID)
        }.sink { _ in } receiveValue: {
            XCTAssertEqual(testDID, $0?.did)
            XCTAssertEqual(testKeyPairIndex, $0?.keyPairIndex)
            XCTAssertEqual(testAlias, $0?.alias)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testStoreNoDuplicatedDID() throws {
        let dao = CDRegisteredDIDDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID = DID(method: "test", methodId: "test")
        let testKeyPairIndex = 0
        let testAlias = "Test"
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID,
            keyPairIndex: testKeyPairIndex,
            alias: testAlias
        ).flatMap {
            dao.addDID(
                did: testDID,
                keyPairIndex: testKeyPairIndex,
                alias: testAlias
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
        let dao = CDRegisteredDIDDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID1 = DID(method: "test1", methodId: "test1")
        let testKeyPairIndex1 = 0
        let testAlias1 = "Test1"

        let testDID2 = DID(method: "test2", methodId: "test2")
        let testKeyPairIndex2 = 1
        let testAlias2 = "Test2"

        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID1,
            keyPairIndex: testKeyPairIndex1,
            alias: testAlias1
        ).flatMap {
            dao.addDID(
                did: testDID2,
                keyPairIndex: testKeyPairIndex2,
                alias: testAlias2
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
        let dao = CDRegisteredDIDDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID1 = DID(method: "test1", methodId: "test1")
        let testKeyPairIndex1 = 0
        let testAlias1 = "Test1"

        let testDID2 = DID(method: "test2", methodId: "test2")
        let testKeyPairIndex2 = 1
        let testAlias2 = "Test2"

        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID1,
            keyPairIndex: testKeyPairIndex1,
            alias: testAlias1
        ).flatMap {
            dao.addDID(
                did: testDID2,
                keyPairIndex: testKeyPairIndex2,
                alias: testAlias2
            )
        }
        .flatMap {
            dao.getDIDInfo(did: testDID2)
        }.sink { _ in } receiveValue: {
            XCTAssertEqual(testDID2, $0?.did)
            XCTAssertEqual(testKeyPairIndex2, $0?.keyPairIndex)
            XCTAssertEqual(testAlias2, $0?.alias)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testGetDIDInfoByAlias() throws {
        let dao = CDRegisteredDIDDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID1 = DID(method: "test1", methodId: "test1")
        let testKeyPairIndex1 = 0
        let testAlias1 = "Test1"

        let testDID2 = DID(method: "test2", methodId: "test2")
        let testKeyPairIndex2 = 1
        let testAlias2 = "Test2"

        let testDID3 = DID(method: "test3", methodId: "test3")
        let testKeyPairIndex3 = 2
        let testAlias3 = "Test2"

        let testAlias = "Test2"

        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID1,
            keyPairIndex: testKeyPairIndex1,
            alias: testAlias1
        ).flatMap {
            dao.addDID(
                did: testDID2,
                keyPairIndex: testKeyPairIndex2,
                alias: testAlias2
            )
        }
        .flatMap {
            dao.addDID(
                did: testDID3,
                keyPairIndex: testKeyPairIndex3,
                alias: testAlias3
            )
        }
        .flatMap {
            dao.getDIDInfo(alias: testAlias)
        }.sink { _ in } receiveValue: {
            XCTAssertEqual($0.count, 2)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testGetDIDInfoByKeyIndex() throws {
        let dao = CDRegisteredDIDDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

        let testDID1 = DID(method: "test1", methodId: "test1")
        let testKeyPairIndex1 = 0
        let testAlias1 = "Test1"

        let testDID2 = DID(method: "test2", methodId: "test2")
        let testKeyPairIndex2 = 1
        let testAlias2 = "Test2"

        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDID(
            did: testDID1,
            keyPairIndex: testKeyPairIndex1,
            alias: testAlias1
        ).flatMap {
            dao.addDID(
                did: testDID2,
                keyPairIndex: testKeyPairIndex2,
                alias: testAlias2
            )
        }
        .flatMap {
            dao.getDIDInfo(keyPairIndex: testKeyPairIndex2)
        }.sink { _ in } receiveValue: {
            XCTAssertEqual(testDID2, $0?.did)
            XCTAssertEqual(testKeyPairIndex2, $0?.keyPairIndex)
            XCTAssertEqual(testAlias2, $0?.alias)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
