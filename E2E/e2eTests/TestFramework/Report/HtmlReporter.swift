import Foundation

class HtmlReporter: Reporter {
    private let pass = "(✔)"
    private let fail = "(✘)"
    
    private var currentFeature: Feature? = nil
    private var currentScenario: Scenario? = nil
    private var currentStep: ConcreteStep? = nil
    private var currentId: String? = nil
    
    private var actions: [String: [ActionOutcome]] = [:]
    
    func beforeFeature(_ feature: Feature) async throws {
        currentFeature = feature
    }
    
    func beforeScenario(_ scenario: Scenario) async throws {
        currentScenario = scenario
    }
    
    func beforeStep(_ step: ConcreteStep) async throws {
        currentStep = step
        currentId = currentFeature!.id + currentScenario!.id + step.id
    }
    
    func action(_ action: ActionOutcome) async throws {
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
        let htmlReport: HtmlReport = HtmlReport()
        for featureOutcome in featuresOutcome {
            let featureReport = FeatureReport()
            featureReport.name = featureOutcome.feature.title()
            htmlReport.data.append(featureReport)
            
            for scenarioOutcome in featureOutcome.scenarios {
                let scenarioReport = ScenarioReport()
                scenarioReport.name = scenarioOutcome.scenario.title
                featureReport.scenarios.append(scenarioReport)
                
                for stepOutcome in scenarioOutcome.steps {
                    let stepReport = StepReport()
                    stepReport.name = stepOutcome.step.action
                    scenarioReport.steps.append(stepReport)
                    
                    let stepId = featureOutcome.feature.id + scenarioOutcome.scenario.id + stepOutcome.step.id
                    if let stepActions = actions[stepId] {
                        for actionOutcome in stepActions {
                            let actionReport = ActionReport()
                            actionReport.action = actionOutcome.action
                            actionReport.passed = actionOutcome.error == nil
                            actionReport.executed = actionOutcome.executed
                            stepReport.actions.append(actionReport)
                            if(actionOutcome.error != nil) {
                                break
                            }
                        }
                    }
                    if (stepOutcome.error != nil) {
                        scenarioReport.passed = false
                        stepReport.passed = false
                        stepReport.error = String(describing: scenarioOutcome.failedStep!.error!)
                        break
                    }
                }
                
                if (scenarioOutcome.failedStep != nil) {
                    featureReport.passed = false
                }
            }
        }
        
        let data = try JSONEncoder().encode(htmlReport.data)
        
        if let path = Bundle.module.path(forResource: "html_report", ofType: "html", inDirectory: "Resources") {
            if let htmlTemplateData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let htmlTemplate = try htmlTemplateData.toString()
                let report = htmlTemplate.replacingOccurrences(of: "{{data}}", with: try data.toString())
                let outputPath = TestConfiguration.shared().targetDirectory().appendingPathComponent("report.html")
                try report.write(to: outputPath, atomically: true, encoding: .utf8)
            }
        }
    }
}

private class HtmlReport: Codable {
    var data: [FeatureReport] = []
}

private class FeatureReport: Codable {
    var name: String = ""
    var passed: Bool = true
    var scenarios: [ScenarioReport] = []
}

private class ScenarioReport: Codable {
    var name: String = ""
    var passed: Bool = true
    var steps: [StepReport] = []
}

private class StepReport: Codable {
    var name: String = ""
    var passed: Bool = true
    var error: String? = nil
    var actions: [ActionReport] = []
}

private class ActionReport: Codable {
    var action: String = ""
    var passed: Bool = true
    var executed: Bool = false
}
