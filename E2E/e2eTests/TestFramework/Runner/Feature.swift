
import Foundation
import XCTest

class Feature: XCTestCase {
    let logger = TestFramework.logger.getLogger(.FEATURE)
    
    private static var featureInitialization: [String] = []
    private static var scenarios: [(Scenario, Error?)] = []
    
    var scenario: Scenario?
    
    func featureTitle() -> String {
        fatalError("Set feature title")
    }
    
    func featureDescription() -> String {
        return ""
    }

    override class func setUp() {
        super.setUp()
        let c: XCTestSuite = XCTestSuite.default.tests[0] as! XCTestSuite
        print("?", c.getTests())
        
        let d = XCTestSuite.default
        print("???", d.getTests())
    }
    
    override func setUp() async throws {

        try await super.setUp()
        try await TestFramework.setUpConfig()
        try await printFeature()
    }
    
    override class func tearDown() {
        printFeatureResume()
        super.tearDown()
    }
    
    override func tearDown() async throws {
        if (scenario == nil) {
            fatalError("To run the feature you have to setup the scenario for each test case.")
        }

        do {
            try await scenario!.run()
            Feature.scenarios.append((scenario!, nil))
        } catch {
            Feature.scenarios.append((scenario!, error))
        }
        
        // print all
        TestFramework.logger.printAll()
        TestFramework.logger.clearAll()
        try await TestFramework.tearDownConfig()
        try await super.tearDown()
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    private func printFeature() async throws {
        let isInitialized: Bool = Feature.featureInitialization.contains(self.className)
        if (isInitialized) {
            return
        }
        Feature.featureInitialization.append(self.className)
        
        logger.info()
        logger.logLine()
        logger.info("Feature:", featureTitle())
        if (!featureDescription().isEmpty) {
            logger.info("Description:", featureDescription())
        }
        logger.logLine()
        logger.flush()
    }
    
    private static func printFeatureResume() {
        let logger = TestFramework.logger.getLogger(.FEATURE)
        
        let defaultSuite = XCTestSuite.default
        
        logger.info("\n")
        logger.logLine()
        logger.info("End-to-end summary")
        logger.logLine()
        var isFailed = false
        scenarios.forEach { scenario in
            if (scenario.1 != nil) {
                isFailed = true
                logger.error(BufferedLogger.fail, scenario.0.name)
            } else {
                logger.info(BufferedLogger.pass, scenario.0.name)
            }
        }
        logger.logLine()
        logger.info("End-to-end result:", (isFailed ? "FAILED" : "PASS"))
        logger.logLine()
        
        logger.flush()
    }
}
