import Domain
@testable import Pluto
import XCTest

final class CDDIDPairDAOTests: XCTestCase {
    private var coreDataManager: CoreDataManager!
    private var privateKeyDao: CDDIDPrivateKeyDAO!
    private var keyRestoration: KeyRestoration!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager(setup: .init(
            modelPath: .storeName("PrismPluto"),
            storeType: .memory
        ))
        keyRestoration = MockKeyRestoration()
        privateKeyDao = CDDIDPrivateKeyDAO(
            keyRestoration: keyRestoration,
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )

    }
    
    func testStoreSingleDIDPair() throws {
        let dao = CDDIDPairDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext,
            privateKeyDIDDAO: privateKeyDao
        )
        
        let testHolderDID = DID(index: 0)
        let testPrivateKey = MockPrivateKey(curve: .x25519)
        let testOtherDID = DID(index: 1)
        let testName = "test"
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = privateKeyDao
            .addDID(did: testHolderDID, privateKeys: [testPrivateKey], alias: nil)
            .flatMap {
                dao.addDIDPair(
                    pair: .init(
                        holder: testHolderDID,
                        other: testOtherDID,
                        name: testName
                    )
                )
            }
            .flatMap {
                dao.getPair(holderDID: testHolderDID).first()
            }.sink { _ in } receiveValue: {
                XCTAssertEqual(testHolderDID, $0?.holder)
                XCTAssertEqual(testOtherDID, $0?.other)
                XCTAssertEqual(testName, $0?.name)
                expectation.fulfill()
            }
        
        waitForExpectations(timeout: 5)
    }
    
    func testWhenHolderNotPersistedThenThrowErrorOnAddingPair() throws {
        let dao = CDDIDPairDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext,
            privateKeyDIDDAO: privateKeyDao
        )
        
        let testHolderDID = DID(index: 0)
        let testOtherDID = DID(index: 1)
        let testName = "test"
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = dao.addDIDPair(
            pair: .init(
                holder: testHolderDID,
                other: testOtherDID,
                name: testName
            )
        )
            .flatMap {
                dao.getPair(holderDID: testHolderDID).first()
            }.sink {
                switch $0 {
                case .failure(let error):
                    XCTAssertEqual(error as? PlutoError, .missingDataPersistence(
                        type: "Holder DID",
                        affecting: "DID Pair")
                    )
                default:
                    XCTFail("Error not thrown")
                }
                expectation.fulfill()
            } receiveValue: { _ in }
        
        waitForExpectations(timeout: 5)
    }
    
    func testStoreNoDuplicatedOtherDIDPair() throws {
        let dao = CDDIDPairDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext,
            privateKeyDIDDAO: privateKeyDao
        )
        
        let testHolderDID1 = DID(index: 0)
        let testHolderDID2 = DID(index: 1)
        let testOtherDID1 = DID(index: 2)
        let testOtherDID2 = DID(index: 2)
        let testPrivateKey = MockPrivateKey(curve: .x25519)
        let testName = "test"
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = privateKeyDao
            .addDID(did: testHolderDID1, privateKeys: [testPrivateKey], alias: nil)
            .flatMap {
                self.privateKeyDao
                    .addDID(did: testHolderDID2, privateKeys: [testPrivateKey], alias: nil)
            }
            .flatMap {
                dao.addDIDPair(pair: .init(
                        holder: testHolderDID1,
                        other: testOtherDID1,
                        name: testName
                    )
                )
            }
            .flatMap {
                dao.addDIDPair(pair: .init(
                    holder: testHolderDID2,
                    other: testOtherDID2,
                    name: testName
                ))
            }
            .flatMap {
                dao.getAll().first()
            }.sink {
                switch $0 {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                default:
                    break
                }
                expectation.fulfill()
            } receiveValue: {
                XCTAssertEqual($0.count, 1)
            }
        
        waitForExpectations(timeout: 5)
    }
    
    func testWhenStoreHolderDIDAlreadyPairedThenThrowError() throws {
        let dao = CDDIDPairDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext,
            privateKeyDIDDAO: privateKeyDao
        )
        
        let testHolderDID = DID(index: 0)
        let testOtherDID1 = DID(index: 1)
        let testOtherDID2 = DID(index: 2)
        let testPrivateKey = MockPrivateKey(curve: .x25519)
        let testName = "test"
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = privateKeyDao
            .addDID(did: testHolderDID, privateKeys: [testPrivateKey], alias: nil)
            .flatMap {
                dao.addDIDPair(pair: .init(
                    holder: testHolderDID,
                    other: testOtherDID1,
                    name: testName
                ))
            }
            .flatMap {
                dao.addDIDPair(pair: .init(
                    holder: testHolderDID,
                    other: testOtherDID2,
                    name: testName
                ))
            }
            .flatMap {
                dao.getAll().first()
            }.sink {
                switch $0 {
                case .failure(let error):
                    XCTAssertEqual(error as? PlutoError, .duplication(type: "Holder DID/DID Pair"))
                default:
                    XCTFail("Error not thrown")
                }
                expectation.fulfill()
            } receiveValue: { _ in }
        
        waitForExpectations(timeout: 999)
    }
    
    func testGetHolderDIDPair() throws {
        let dao = CDDIDPairDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext,
            privateKeyDIDDAO: privateKeyDao
        )
        
        let testHolderDID1 = DID(index: 0)
        let testHolderDID2 = DID(index: 1)
        let testOtherDID1 = DID(index: 2)
        let testOtherDID2 = DID(index: 3)
        let testPrivateKey = MockPrivateKey(curve: .x25519)
        let testName = "test"
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = privateKeyDao
            .addDID(did: testHolderDID1, privateKeys: [testPrivateKey], alias: nil)
            .flatMap {
                self.privateKeyDao
                    .addDID(did: testHolderDID2, privateKeys: [testPrivateKey], alias: nil)
            }
            .flatMap {
                dao.addDIDPair(pair: .init(
                    holder: testHolderDID1,
                    other: testOtherDID1,
                    name: testName
                ))
            }
            .flatMap {
                dao.addDIDPair(pair: .init(
                    holder: testHolderDID2,
                    other: testOtherDID2,
                    name: testName
                ))
            }
            .flatMap {
                dao.getPair(holderDID: testHolderDID2).first()
            }.sink {
                switch $0 {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                default:
                    break
                }
                expectation.fulfill()
            } receiveValue: {
                XCTAssertEqual($0?.holder, testHolderDID2)
                XCTAssertEqual($0?.other, testOtherDID2)
            }
        
        waitForExpectations(timeout: 5)
    }
}
