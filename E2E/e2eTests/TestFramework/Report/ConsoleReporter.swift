import Foundation

class ConsoleReporter: Reporter {
    private let pass = "(✔)"
    private let fail = "(✘)"

    private var actions: [String] = []
    
    func beforeFeature(_ feature: Feature) async throws {
        print()
        print("Feature:", feature.title())
    }
    
    func beforeScenario(_ scenario: Scenario) async throws {
        print("    ", scenario.title)
    }
    
    func beforeStep(_ step: ConcreteStep) async throws {
    }
    
    func action(_ action: String) async throws {
        actions.append(action)
    }
    
    func afterStep(_ stepOutcome: StepOutcome) async throws {
        let result = stepOutcome.error != nil ? fail : pass
        print("      ", result, stepOutcome.step.action)
        actions.forEach { action in
            print("            ", action)
        }
        actions = []
    }
    
    func afterScenario(_ scenarioOutcome: ScenarioOutcome) async throws {
        let result = scenarioOutcome.failedStep != nil ? "FAIL" : "PASS"
        print("    ", "Result:", result)
    }
    
    func afterFeature(_ featureOutcome: FeatureOutcome) async throws {
        print()
    }
    
    func afterFeatures(_ featuresOutcome: [FeatureOutcome]) async throws {
    }
}
