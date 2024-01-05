import Foundation

class HtmlReporter: Reporter {
    private let pass = "(✔)"
    private let fail = "(✘)"
    
    private var currentFeature: Feature? = nil
    private var currentScenario: Scenario? = nil
    private var currentStep: StepInstance? = nil
    private var currentId: String? = nil
    
    private var actions: [String: [String]] = [:]
    
    func beforeFeature(_ feature: Feature) async throws {
        currentFeature = feature
    }
    
    func beforeScenario(_ scenario: Scenario) async throws {
        currentScenario = scenario
    }
    
    func beforeStep(_ step: StepInstance) async throws {
        currentStep = step
        currentId = currentFeature!.id + currentScenario!.id + step.id
    }
    
    func action(_ action: String) async throws {
        if (actions[currentId!] == nil) {
            actions[currentId!] = []
        }
        actions[currentId!]!.append(action)
    }
    
    func afterStep(_ stepOutcome: StepOutcome) async throws {
        currentStep = nil
    }
    
    func afterScenario(_ scenarioOutcome: ScenarioOutcome) async throws {
        currentScenario = nil
    }
    
    func afterFeature(_ featureOutcome: FeatureOutcome) async throws {
        currentFeature = nil
    }
    
    func afterFeatures(_ featuresOutcome: [FeatureOutcome]) async throws {

        var summary = ""
        summary.append("Executed \(featuresOutcome.count) features\n")
        
        for featureOutcome in featuresOutcome {
            summary.append("  Feature: \(featureOutcome.feature.title())\n")
            
            for scenarioOutcome in featureOutcome.scenarios {
                summary.append("    Scenario: \(scenarioOutcome.scenario.title)\n")
                
                for stepOutcome in scenarioOutcome.steps {
                    if (stepOutcome.error != nil) {
                        summary.append("      \(fail) \(stepOutcome.step.step)\n")
                        summary.append("           caused by: \(String(describing: scenarioOutcome.error!))\n")
                    } else {
                        summary.append("      \(pass) \(stepOutcome.step.step)\n")
                    }
                    let stepId = featureOutcome.feature.id + scenarioOutcome.scenario.id + stepOutcome.step.id
                    if let stepActions = actions[stepId] {
                        for action in stepActions {
                            summary.append("            \(action)\n")
                        }
                    }
                }
                
                if (scenarioOutcome.error != nil) {
                    summary.append("    Status: FAILED\n")
                } else {
                    summary.append("    Status: SUCCESS\n")
                }
                
                summary.append("\n")
                
            }
        }
        
        let outputPath = TestConfiguration.getTargetPath().appendingPathComponent("Test.txt")
        try summary.write(to: outputPath, atomically: true, encoding: .utf8)
    }
}
