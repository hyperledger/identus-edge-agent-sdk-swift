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
    
    func beforeStep(_ step: StepInstance) async throws {
        printDot()
    }
    
    func action(_ action: String) async throws {
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
                    scenarioOutcome.error != nil ? "(fail)" : "(pass)",
                    scenarioOutcome.scenario.title
                )
                if (scenarioOutcome.error != nil) {
                    let error = scenarioOutcome.error!
                    print("      ", "caused by:", error)
                }
            }
        }
    }
}
