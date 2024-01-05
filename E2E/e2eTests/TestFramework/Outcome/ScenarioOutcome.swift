import Foundation

class ScenarioOutcome {
    let scenario: Scenario
    var steps: [StepOutcome] = []
    var error: Error? = nil
    
    init(_ scenario: Scenario) {
        self.scenario = scenario
    }
}
