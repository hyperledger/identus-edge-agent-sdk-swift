
import Foundation
import XCTest

class Feature: XCTestCase {
    private static var featureInitialization: [String] = []
    
    func featureTitle() -> String {
        fatalError("Set feature title")
    }
    
    func featureDescription() -> String {
        return ""
    }

    override func setUp() async throws {
        try await CucumberConfig.setUpConfig()

        let isInitialized: Bool = Feature.featureInitialization.contains(self.className)
        if (!isInitialized) {
            try await printFeature()
            Feature.featureInitialization.append(self.className)
        }
    }
    
    override func tearDown() async throws {
        try await CucumberConfig.tearDownConfig()
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    private func printFeature() async throws {
        CucumberLogger.info()
        CucumberLogger.logLine()
        CucumberLogger.info("Feature:", featureTitle())
        if (!featureDescription().isEmpty) {
            CucumberLogger.info("Description:", featureDescription())
        }
        CucumberLogger.logLine()
    }
}
