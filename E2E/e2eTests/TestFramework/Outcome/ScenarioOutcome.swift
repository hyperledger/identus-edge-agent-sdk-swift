import Foundation

class ScenarioOutcome {
    let scenario: Scenario
    var steps: [StepOutcome] = []
    var failedStep: StepOutcome? = nil
    
    init(_ scenario: Scenario) {
        self.scenario = scenario
    }
}
