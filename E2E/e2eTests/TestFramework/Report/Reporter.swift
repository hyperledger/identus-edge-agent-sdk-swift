import Foundation

protocol Reporter {
    func beforeFeature(_ feature: Feature) async throws
    func beforeScenario(_ scenario: Scenario) async throws
    func beforeStep(_ step: StepInstance) async throws
    func action(_ action: String) async throws
    func afterStep(_ stepOutcome: StepOutcome) async throws
    func afterScenario(_ scenarioOutcome: ScenarioOutcome) async throws
    func afterFeature(_ featureOutcome: FeatureOutcome) async throws
    func afterFeatures(_ featuresOutcome: [FeatureOutcome]) async throws
}
