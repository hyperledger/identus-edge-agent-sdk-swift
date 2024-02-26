import Foundation

class DotReporter: Reporter {
    private func printDot() {
        print(".", terminator: "")
    }
    func beforeFeature(_ feature: Feature) async throws {
        printDot()
    }
    
    func beforeScenario(_ scenario: Scenario) async throws {
        printDot()
    }
    
    func beforeStep(_ step: ConcreteStep) async throws {
        printDot()
    }
    
    func action(_ action: ActionOutcome) async throws {
        printDot()
    }
    
    func afterStep(_ stepOutcome: StepOutcome) async throws {
        printDot()
    }
    
    func afterScenario(_ scenarioOutcome: ScenarioOutcome) async throws {
        print()
    }
    
    func afterFeature(_ featureOutcome: FeatureOutcome) async throws {
    }
    
    func afterFeatures(_ featuresOutcome: [FeatureOutcome]) async throws {
        print("Executed", featuresOutcome.count, "features")
        for featureOutcome in featuresOutcome {
            print("  ", "Feature:", featureOutcome.feature.title())
            for scenarioOutcome in featureOutcome.scenarios {
                print(
                    "    ",
                    scenarioOutcome.failedStep != nil ? "(fail)" : "(pass)",
                    scenarioOutcome.scenario.title
                )
                if (scenarioOutcome.failedStep != nil) {
                    let failedStep = scenarioOutcome.failedStep!
                    print("          ", failedStep.error!)
                    print("           at step: \"\(failedStep.step.action)\"")
                }
            }
        }
    }
}
