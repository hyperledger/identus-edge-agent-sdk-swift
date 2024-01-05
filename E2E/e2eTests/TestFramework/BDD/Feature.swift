
import Foundation
import XCTest

class Feature: XCTestCase {   
    let id: String = UUID().uuidString
    var currentScenario: Scenario? = nil
    
    func title() -> String {
        fatalError("Set feature title")
    }
    
    func description() -> String {
        return ""
    }

    /// our lifecycle starts after xctest is ending
    override func tearDown() async throws {
        try await run()
        try await super.tearDown()
    }

    override class func tearDown() {
        // signal end of feature
        TestConfiguration.shared().endCurrentFeature()
    }
    
    func run() async throws {
        // check if we have the scenario
        if (currentScenario == nil) {
            fatalError("""
            To run the feature you have to setup the scenario for each test case.
            Usage:
            func testMyScenario() async throws {
                scenario = Scenario("description")
                    .given // ...
            }
            """)
        }
        
        try await TestConfiguration.setUpInstance()
        try await TestConfiguration.shared().run(self, currentScenario!)
    }
}
