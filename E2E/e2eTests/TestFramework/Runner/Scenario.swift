import Foundation

class Scenario {
    let scenarioLogger = TestFramework.logger.getLogger(.SCENARIO)
    let stepLogger = TestFramework.logger.getLogger(.STEP)
    let taskLogger = TestFramework.logger.getLogger(.TASK)
    
    var name: String
    private var lastContext: String = ""
    private var stepList: [StepInstance] = []
    
    init(_ name: String) {
        self.name = name
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
        let error = try await executeSteps()
        printResult(hasFailed: error != nil)
        
        if (error != nil) {
            throw error!
        }
    }
    
    private func printScenario() {
        scenarioLogger.logLine()
        scenarioLogger.info("Scenario:", name)
        scenarioLogger.logLine()
    }
    
    private func executeSteps() async throws -> Error? {
        var lastContext = ""
        var delegatedError: Error? = nil
        
        // set default to task logger when running steps
        TestFramework.logger.setLevel(.TASK)

        for step in stepList {
            stepLogger.info(step.context == lastContext ? "And" : step.context, step.step)
            do {
                try await StepRegistry.run(step.step)
            } catch {
                delegatedError = error
            }
            lastContext = step.context
            if (delegatedError != nil) {
                break
            }
        }
        
        stepLogger.appendResultToLast(hasFailed: delegatedError != nil)
        taskLogger.appendResultToLast(hasFailed: delegatedError != nil)
        
        return delegatedError
    }
    
    private func printResult(hasFailed: Bool) {
        scenarioLogger.logLine()
        scenarioLogger.info("Result:", hasFailed ? "FAILED" : "PASS")
        scenarioLogger.logLine()
    }
}
