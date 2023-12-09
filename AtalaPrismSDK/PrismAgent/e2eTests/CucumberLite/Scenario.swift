import Foundation

class Scenario {
    var scenario: String
    private var lastContext: String = ""
    private var stepList: [StepInstance] = []
    
    init(_ scenario: String) {
        self.scenario = scenario
    }
    
    private func addStep(_ step: String) {
        let stepInstance = StepInstance()
        stepInstance.context = lastContext
        stepInstance.step = step
        stepList.append(stepInstance)
    }

    func given(_ step: String) -> Scenario {
        lastContext = "Given"
        addStep(step)
        return self
    }
    
    func when(_ step: String) -> Scenario {
        lastContext = "When"
        addStep(step)
        return self
    }
    
    func then(_ step: String) -> Scenario {
        lastContext = "Then"
        addStep(step)
        return self
    }
    
    func but(_ step: String) -> Scenario {
        lastContext = "But"
        addStep(step)
        return self
    }
    
    func and(_ step: String) -> Scenario {
        if (lastContext.isEmpty) {
            fatalError("Trying to add an [and] step without previous context.")
        }
        addStep(step)
        return self
    }
    
    func run() async throws {
        printScenario()
        try await executeSteps()
        printResult()
    }
    
    private func printScenario() {
        CucumberLogger.logLine()
        CucumberLogger.info("Scenario:", scenario)
        CucumberLogger.logLine()
    }
    
    private func executeSteps() async throws {
        var lastContext = ""
        for step in stepList {
            CucumberLogger.info("    ", step.context == lastContext ? "And" : step.context, step.step)
            try await StepRegistry.run(step.step)
            lastContext = step.context
        }
    }
    
    private func printResult() {
        CucumberLogger.logLine()
        CucumberLogger.info("Result:", "TO BE DONE")
        CucumberLogger.logLine()
    }
}
