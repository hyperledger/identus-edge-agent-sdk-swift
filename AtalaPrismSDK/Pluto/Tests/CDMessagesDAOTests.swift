import Domain
@testable import Pluto
import XCTest

final class CDMessagesDAOTests: XCTestCase {
    private var coreDataManager: CoreDataManager!
    private var privateDAO: CDDIDPrivateKeyDAO!
    private var pairDAO: CDDIDPairDAO!

    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManager(setup: .init(
            modelPath: .storeName("PrismPluto"),
            storeType: .memory
        ))
        privateDAO = CDDIDPrivateKeyDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext
        )
        pairDAO = CDDIDPairDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext,
            privateKeyDIDDAO: privateDAO
        )
    }

    func testStoreMessage() throws {
        let dao = CDMessageDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext,
            pairDAO: pairDAO
        )
        let testHolderDID = DID(index: 0)
        let testPrivateKey = PrivateKey(curve: .x25519, value: Data())
        let testOtherDID = DID(index: 1)
        let testName = "test"
        let testMessage = Message(
            piuri: "test",
            from: testHolderDID,
            to: testOtherDID,
            body: Data()
        )
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = privateDAO
            .addDID(did: testHolderDID, privateKeys: [testPrivateKey], alias: nil)
            .flatMap {
                self.pairDAO.addDIDPair(pair: .init(
                    holder: testHolderDID,
                    other: testOtherDID,
                    name: testName
                ))
            }
            .flatMap {
                dao.addMessage(msg: testMessage, direction: .received)
            }
            .flatMap {
                dao.getMessage(id: testMessage.id).first()
            }.sink {
                switch $0 {
                case .failure(let error):
                    print(error.localizedDescription)
                    XCTFail(error.localizedDescription)
                default:
                    break
                }
                expectation.fulfill()
            } receiveValue: {
                XCTAssertEqual(testMessage, $0)
            }

        waitForExpectations(timeout: 5)
    }

    func testStoreNoDuplicatedMessage() throws {
        let dao = CDMessageDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext,
            pairDAO: pairDAO
        )
        let testHolderDID = DID(index: 0)
        let testPrivateKey = PrivateKey(curve: .x25519, value: Data())
        let testOtherDID = DID(index: 1)
        let testName = "test"
        let testMessage = Message(
            piuri: "test",
            from: testHolderDID,
            to: testOtherDID,
            body: Data()
        )
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = privateDAO
            .addDID(did: testHolderDID, privateKeys: [testPrivateKey], alias: nil)
            .flatMap {
                self.pairDAO.addDIDPair(pair: .init(
                    holder: testHolderDID,
                    other: testOtherDID,
                    name: testName
                ))
            }
            .flatMap {
                dao.addMessage(msg: testMessage, direction: .received)
            }
            .flatMap {
                dao.addMessage(msg: testMessage, direction: .received)
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
            } receiveValue: {
                XCTAssertEqual($0.count, 1)
                expectation.fulfill()
            }

        waitForExpectations(timeout: 5)
    }

    func testGetMessageForDIDPairComponent() throws {
        let dao = CDMessageDAO(
            readContext: coreDataManager.mainContext,
            writeContext: coreDataManager.editContext,
            pairDAO: pairDAO
        )
        let testHolderDID = DID(index: 0)
        let testPrivateKey = PrivateKey(curve: .ed25519, value: Data())
        let testOtherDID = DID(index: 1)
        let testHolderDID2 = DID(index: 2)
        let testPrivateKey2 = PrivateKey(curve: .x25519, value: Data())
        let testOtherDID2 = DID(index: 3)
        let testName = "test"
        let testMessage1 = Message(
            piuri: "test",
            from: testHolderDID,
            to: testOtherDID,
            body: Data()
        )
        let testMessage2 = Message(
            piuri: "test2",
            from: testHolderDID2,
            to: testOtherDID2,
            body: Data()
        )
        let expectation = expectation(description: "Awaiting publisher")
        let cancellable = privateDAO
            .addDID(did: testHolderDID, privateKeys: [testPrivateKey], alias: nil)
            .flatMap {
                self.privateDAO
                    .addDID(did: testHolderDID2, privateKeys: [testPrivateKey2], alias: nil)
            }
            .flatMap {
                self.pairDAO.addDIDPair(pair: .init(
                    holder: testHolderDID,
                    other: testOtherDID,
                    name: testName
                ))
            }
            .flatMap {
                self.pairDAO.addDIDPair(pair: .init(
                    holder: testHolderDID2,
                    other: testOtherDID2,
                    name: testName
                ))
            }
            .flatMap {
                dao.addMessage(msg: testMessage1, direction: .received)
            }
            .flatMap {
                dao.addMessage(msg: testMessage2, direction: .received)
            }
            .flatMap {
                dao.getAllFor(did: testHolderDID2).first()
            }.sink {
                switch $0 {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                default:
                    break
                }
                expectation.fulfill()
            } receiveValue: {
                XCTAssertEqual(testMessage2, $0.first)
            }

        waitForExpectations(timeout: 5)
    }
}

extension Message: Equatable {
    public static func == (lhs: Domain.Message, rhs: Domain.Message) -> Bool {
        lhs.id == rhs.id && lhs.piuri == rhs.piuri
    }
}
